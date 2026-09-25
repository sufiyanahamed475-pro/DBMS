USE InventoryDB;

-- ============================================================
-- TASK VII: SQL QUERY IMPLEMENTATION FOR E-COMMERCE DATABASE
-- ============================================================

-- 1. SELECT: Display all products
SELECT *
FROM Product;

-- 2. SELECT: Retrieve important product information
SELECT
    product_id,
    product_name,
    price,
    stock
FROM Product;

-- 3. WHERE: Search products below a selected price
SELECT
    product_id,
    product_name,
    price,
    stock
FROM Product
WHERE price < 100
ORDER BY price ASC;

-- 4. WHERE: Search products within a price range
SELECT
    product_id,
    product_name,
    price
FROM Product
WHERE price BETWEEN 10 AND 150
ORDER BY price ASC;

-- 5. ORDER BY: Products from highest to lowest price
SELECT
    product_id,
    product_name,
    price
FROM Product
ORDER BY price DESC;

-- 6. DISTINCT: Display unique categories
SELECT DISTINCT
    c.category_name
FROM Category c
JOIN Product p
    ON c.category_id = p.category_id
ORDER BY c.category_name;

-- 7. Search products by category
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.stock
FROM Product p
JOIN Category c
    ON p.category_id = c.category_id
WHERE c.category_name = 'Electronics'
ORDER BY p.product_name;

-- 8. Search available products
-- stock greater than zero means the product is available
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.stock,
    'Available' AS availability
FROM Product p
JOIN Category c
    ON p.category_id = c.category_id
WHERE p.stock > 0
ORDER BY p.stock DESC;

-- 9. Search unavailable products
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.stock,
    'Unavailable' AS availability
FROM Product p
JOIN Category c
    ON p.category_id = c.category_id
WHERE p.stock = 0
ORDER BY p.product_name;

-- 10. Search products by price, category, and availability together
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.stock
FROM Product p
JOIN Category c
    ON p.category_id = c.category_id
WHERE p.price <= 150
  AND c.category_name = 'Electronics'
  AND p.stock > 0
ORDER BY p.price ASC;

-- 11. Retrieve customer information
SELECT
    customer_id,
    customer_name,
    email,
    phone,
    address
FROM Customer
ORDER BY customer_name;

-- 12. Retrieve customer and product information from orders
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    p.product_id,
    p.product_name,
    od.quantity,
    od.unit_price,
    od.subtotal,
    o.order_status
FROM Customer c
JOIN Orders o
    ON c.customer_id = o.customer_id
JOIN Order_Details od
    ON o.order_id = od.order_id
JOIN Product p
    ON od.product_id = p.product_id
ORDER BY o.order_date DESC, c.customer_name, p.product_name;

-- 13. Apply multiple filtering conditions
-- Confirmed orders with total amount greater than 20
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total_amount,
    o.order_status
FROM Orders o
JOIN Customer c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Confirmed'
  AND o.total_amount > 20
ORDER BY o.total_amount DESC;

-- 14. Filter products using LIKE
SELECT
    product_id,
    product_name,
    price,
    stock
FROM Product
WHERE product_name LIKE '%Oil%'
ORDER BY product_name;

-- 15. Basic business report: product count and average price by category
SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count,
    ROUND(AVG(p.price), 2) AS average_price
FROM Category c
LEFT JOIN Product p
    ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY product_count DESC;

-- 16. Basic business report: inventory status
SELECT
    c.category_name,
    COUNT(p.product_id) AS total_products,
    SUM(CASE WHEN p.stock > 0 THEN 1 ELSE 0 END) AS available_products,
    SUM(CASE WHEN p.stock = 0 THEN 1 ELSE 0 END) AS unavailable_products,
    SUM(p.stock) AS total_stock
FROM Category c
LEFT JOIN Product p
    ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;

-- 17. Basic business report: total orders and spending by customer
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM Customer c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

-- 18. Basic business report: payment status summary
SELECT
    payment_status,
    COUNT(*) AS transaction_count,
    COALESCE(SUM(amount), 0) AS total_amount
FROM Payment
GROUP BY payment_status
ORDER BY total_amount DESC;

-- 19. Basic business report: top-selling products
SELECT
    p.product_id,
    p.product_name,
    SUM(od.quantity) AS total_quantity_sold,
    ROUND(SUM(od.subtotal), 2) AS sales_value
FROM Product p
JOIN Order_Details od
    ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC, sales_value DESC;

-- 20. Basic business report: product rating summary
SELECT
    p.product_id,
    p.product_name,
    COUNT(r.rating_id) AS number_of_ratings,
    ROUND(AVG(r.rating_value), 2) AS average_rating
FROM Product p
LEFT JOIN Rating r
    ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
ORDER BY average_rating DESC, p.product_name;
