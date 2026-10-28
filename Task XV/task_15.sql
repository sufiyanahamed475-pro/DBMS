USE InventoryDB;

-- TASK XV: E-COMMERCE INTELLIGENCE PLATFORM CAPSTONE
-- Integration and reporting layer for the tables built in Tasks II-VI.
-- This script is read-only apart from creating/replacing a view.

CREATE OR REPLACE VIEW vw_capstone_order_intelligence AS
SELECT o.order_id, o.order_date, o.order_status,
       c.customer_id, c.customer_name,
       COUNT(DISTINCT od.product_id) AS distinct_products,
       COALESCE(SUM(od.quantity), 0) AS units_ordered,
       o.total_amount,
       COALESCE(SUM(p.amount), 0.00) AS recorded_payment_amount,
       GROUP_CONCAT(DISTINCT p.payment_status ORDER BY p.payment_status SEPARATOR ', ') AS payment_statuses
FROM Orders o
JOIN Customer c ON c.customer_id = o.customer_id
LEFT JOIN Order_Details od ON od.order_id = o.order_id
LEFT JOIN Payment p ON p.order_id = o.order_id
GROUP BY o.order_id, o.order_date, o.order_status,
         c.customer_id, c.customer_name, o.total_amount;

-- 1. Relationship / normalization check: show each order with its customer.
SELECT o.order_id, c.customer_id, c.customer_name,
       o.order_date, o.order_status, o.total_amount
FROM Orders o
JOIN Customer c ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- 2. Inventory health: identify products that may need restocking.
SELECT p.product_id, p.product_name, c.category_name, p.stock, p.price,
       CASE WHEN p.stock = 0 THEN 'OUT OF STOCK'
            WHEN p.stock <= 5 THEN 'LOW STOCK'
            ELSE 'IN STOCK' END AS stock_status
FROM Product p
JOIN Category c ON c.category_id = p.category_id
ORDER BY p.stock ASC, p.product_name;

-- 3. Management KPI summary.
SELECT
    (SELECT COUNT(*) FROM Customer) AS total_customers,
    (SELECT COUNT(*) FROM Product) AS total_products,
    (SELECT COALESCE(SUM(stock), 0) FROM Product) AS total_units_in_inventory,
    (SELECT COUNT(*) FROM Orders) AS total_orders,
    (SELECT ROUND(COALESCE(SUM(total_amount), 0), 2) FROM Orders
      WHERE order_status <> 'Cancelled') AS non_cancelled_order_value,
    (SELECT COUNT(*) FROM Payment WHERE payment_status = 'Successful') AS successful_payments,
    (SELECT COUNT(*) FROM Payment WHERE payment_status = 'Failed') AS failed_payments;

-- 4. Customer insights: repeat vs one-time vs not-yet-purchased customers.
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.order_id) AS order_count,
       ROUND(COALESCE(SUM(o.total_amount), 0), 2) AS total_spend,
       CASE WHEN COUNT(DISTINCT o.order_id) = 0 THEN 'No Purchase'
            WHEN COUNT(DISTINCT o.order_id) = 1 THEN 'One-Time Customer'
            ELSE 'Repeat Customer' END AS customer_type
FROM Customer c
LEFT JOIN Orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spend DESC;

-- 5. Product performance by category.
SELECT c.category_name, p.product_name,
       COALESCE(SUM(od.quantity), 0) AS units_sold,
       COALESCE(ROUND(SUM(od.subtotal), 2), 0.00) AS sales_value,
       COALESCE(ROUND(AVG(r.rating_value), 2), 0.00) AS average_rating
FROM Category c
JOIN Product p ON p.category_id = c.category_id
LEFT JOIN Order_Details od ON od.product_id = p.product_id
LEFT JOIN Rating r ON r.product_id = p.product_id
GROUP BY c.category_id, c.category_name, p.product_id, p.product_name
ORDER BY c.category_name, sales_value DESC;

-- 6. Integrated order and payment view.
SELECT * FROM vw_capstone_order_intelligence
ORDER BY order_date DESC, order_id DESC;

-- Suggested business insights to discuss after running:
-- * Low-stock items are candidates for replenishment.
-- * Compare category sales and ratings to identify strong products.
-- * Monitor failed payments and orders without successful payments.
-- * Segment customers by order frequency and spending.
-- Metrics depend on the actual data loaded into InventoryDB.
