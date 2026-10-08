USE InventoryDB;

-- ============================================================
-- TASK IX: SALES AND CUSTOMER ANALYTICS SYSTEM
-- ============================================================

-- 1. Apply COUNT(), SUM(), AVG(), MIN(), MAX()
SELECT COUNT(*) AS total_orders,
       SUM(total_amount) AS total_sales,
       ROUND(AVG(total_amount), 2) AS average_order_value,
       MIN(total_amount) AS minimum_order_value,
       MAX(total_amount) AS maximum_order_value
FROM Orders;

-- 2. Generate total sales report
SELECT o.order_id, c.customer_name, o.order_date,
       o.total_amount, o.order_status
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
ORDER BY o.total_amount DESC;

SELECT COUNT(*) AS number_of_orders,
       ROUND(SUM(total_amount), 2) AS total_sales
FROM Orders
WHERE order_status IN ('Confirmed', 'Pending');

-- 3. Find top customers based on purchase amount
SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS total_orders,
       ROUND(SUM(o.total_amount), 2) AS total_purchase_amount
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_purchase_amount DESC
LIMIT 5;

-- 4. Identify best-selling products
SELECT p.product_id, p.product_name,
       SUM(od.quantity) AS quantity_sold,
       ROUND(SUM(od.subtotal), 2) AS sales_amount
FROM Product p
JOIN Order_Details od ON p.product_id = od.product_id
JOIN Orders o ON od.order_id = o.order_id
WHERE o.order_status IN ('Confirmed', 'Pending')
GROUP BY p.product_id, p.product_name
ORDER BY quantity_sold DESC, sales_amount DESC
LIMIT 5;

-- 5. Category-wise sales analysis
SELECT c.category_id, c.category_name,
       COUNT(DISTINCT o.order_id) AS number_of_orders,
       SUM(od.quantity) AS units_sold,
       ROUND(SUM(od.subtotal), 2) AS category_sales
FROM Category c
JOIN Product p ON c.category_id = p.category_id
JOIN Order_Details od ON p.product_id = od.product_id
JOIN Orders o ON od.order_id = o.order_id
WHERE o.order_status IN ('Confirmed', 'Pending')
GROUP BY c.category_id, c.category_name
ORDER BY category_sales DESC;

-- 6. Customer sales summary using aggregate functions
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.order_id) AS order_count,
       ROUND(SUM(o.total_amount), 2) AS total_spent,
       ROUND(AVG(o.total_amount), 2) AS average_order_value,
       MIN(o.total_amount) AS minimum_order,
       MAX(o.total_amount) AS maximum_order
FROM Customer c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;
