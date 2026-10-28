USE InventoryDB;

-- TASK XIII: SECURITY AND PERFORMANCE
-- Run account/role statements only as an administrator in a test environment.
-- Replace the example password before execution. Never commit real credentials.

-- MySQL 8.0 role and account examples (optional):
-- CREATE ROLE IF NOT EXISTS 'inventory_reader';
-- CREATE USER IF NOT EXISTS 'inventory_analyst'@'localhost' IDENTIFIED BY 'Replace-With-A-Strong-Password';
-- GRANT SELECT ON InventoryDB.vw_order_summary TO 'inventory_reader';
-- GRANT SELECT ON InventoryDB.vw_product_sales_summary TO 'inventory_reader';
-- GRANT 'inventory_reader' TO 'inventory_analyst'@'localhost';
-- SET DEFAULT ROLE 'inventory_reader' TO 'inventory_analyst'@'localhost';
-- REVOKE SELECT ON InventoryDB.vw_product_sales_summary FROM 'inventory_reader';

-- Indexes support common foreign-key joins and filtering.
-- CREATE INDEX fails if the same named index already exists; inspect SHOW INDEX first.
CREATE INDEX idx_orders_customer_date ON Orders(customer_id, order_date);
CREATE INDEX idx_orders_status_date ON Orders(order_status, order_date);
CREATE INDEX idx_order_details_product_order ON Order_Details(product_id, order_id);
CREATE INDEX idx_payment_status_date ON Payment(payment_status, payment_date);
CREATE INDEX idx_product_category_price ON Product(category_id, price);

-- Inspect indexes and schema.
SHOW INDEX FROM Orders;
SHOW INDEX FROM Order_Details;
SHOW INDEX FROM Payment;
SHOW INDEX FROM Product;

-- EXPLAIN reveals the execution plan; compare before and after adding indexes.
EXPLAIN
SELECT o.order_id, o.order_date, o.total_amount
FROM Orders o
WHERE o.customer_id = 1
ORDER BY o.order_date DESC;

EXPLAIN
SELECT p.product_id, p.product_name, p.price, c.category_name
FROM Product p
JOIN Category c ON c.category_id = p.category_id
WHERE p.category_id = 1 AND p.price > 20
ORDER BY p.price;

EXPLAIN
SELECT payment_status, COUNT(*) AS transactions, SUM(amount) AS total_amount
FROM Payment
WHERE payment_date >= '2026-01-01'
GROUP BY payment_status;

-- Principle: indexes can speed up reads but add storage and write overhead.
-- Grant only the minimum privileges required; avoid granting ALL on the whole database.
