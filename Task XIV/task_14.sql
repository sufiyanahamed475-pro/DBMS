USE InventoryDB;

-- TASK XIV: BI AND AI DATA PREPARATION
-- Requires MySQL 8.0+ for window functions.

-- 1. Rank customers by lifetime order value.
WITH customer_metrics AS (
    SELECT c.customer_id, c.customer_name,
           COUNT(DISTINCT o.order_id) AS order_count,
           COALESCE(SUM(o.total_amount), 0.00) AS lifetime_spend,
           COALESCE(AVG(o.total_amount), 0.00) AS average_order_value,
           MAX(o.order_date) AS last_order_date
    FROM Customer c
    LEFT JOIN Orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, order_count,
       ROUND(lifetime_spend, 2) AS lifetime_spend,
       ROUND(average_order_value, 2) AS average_order_value,
       last_order_date,
       RANK() OVER (ORDER BY lifetime_spend DESC) AS spend_rank,
       ROW_NUMBER() OVER (ORDER BY lifetime_spend DESC, customer_id) AS customer_row_number
FROM customer_metrics
ORDER BY spend_rank, customer_id;

-- 2. Customer segmentation using transparent business rules.
WITH customer_metrics AS (
    SELECT c.customer_id, c.customer_name,
           COUNT(DISTINCT o.order_id) AS order_count,
           COALESCE(SUM(o.total_amount), 0.00) AS lifetime_spend,
           MAX(o.order_date) AS last_order_date
    FROM Customer c
    LEFT JOIN Orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, order_count,
       ROUND(lifetime_spend, 2) AS lifetime_spend, last_order_date,
       CASE
         WHEN order_count = 0 THEN 'No Orders'
         WHEN lifetime_spend >= 500 THEN 'High Value'
         WHEN lifetime_spend >= 100 THEN 'Regular'
         ELSE 'Occasional'
       END AS customer_segment
FROM customer_metrics
ORDER BY lifetime_spend DESC;

-- 3. Category performance and contribution to total recorded line-item sales.
WITH category_sales AS (
    SELECT c.category_id, c.category_name,
           COALESCE(SUM(od.subtotal), 0.00) AS sales_value,
           COALESCE(SUM(od.quantity), 0) AS units_sold
    FROM Category c
    LEFT JOIN Product p ON p.category_id = c.category_id
    LEFT JOIN Order_Details od ON od.product_id = p.product_id
    GROUP BY c.category_id, c.category_name
)
SELECT category_id, category_name, units_sold,
       ROUND(sales_value, 2) AS sales_value,
       ROUND(100 * sales_value / NULLIF(SUM(sales_value) OVER (), 0), 2) AS sales_percentage,
       RANK() OVER (ORDER BY sales_value DESC) AS sales_rank
FROM category_sales
ORDER BY sales_rank, category_name;

-- 4. AI/ML feature dataset: one row per customer.
-- Export the result as CSV. Keep labels/targets separate from input features
-- when training a predictive model to avoid data leakage.
SELECT c.customer_id,
       COUNT(DISTINCT o.order_id) AS order_count,
       ROUND(COALESCE(SUM(o.total_amount), 0), 2) AS lifetime_spend,
       ROUND(COALESCE(AVG(o.total_amount), 0), 2) AS average_order_value,
       COALESCE(SUM(od.quantity), 0) AS total_units_purchased,
       COUNT(DISTINCT od.product_id) AS distinct_products_purchased,
       DATEDIFF(CURRENT_DATE, MAX(o.order_date)) AS days_since_last_order,
       COALESCE(AVG(r.rating_value), 0) AS average_rating_given
FROM Customer c
LEFT JOIN Orders o ON o.customer_id = c.customer_id
LEFT JOIN Order_Details od ON od.order_id = o.order_id
LEFT JOIN Rating r ON r.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY c.customer_id;

-- 5. Product feature dataset for BI / demand analysis.
SELECT p.product_id, p.product_name, c.category_name, p.price, p.stock,
       COALESCE(SUM(od.quantity), 0) AS units_sold,
       COALESCE(ROUND(SUM(od.subtotal), 2), 0.00) AS sales_value,
       COALESCE(ROUND(AVG(r.rating_value), 2), 0.00) AS average_rating
FROM Product p
JOIN Category c ON c.category_id = p.category_id
LEFT JOIN Order_Details od ON od.product_id = p.product_id
LEFT JOIN Rating r ON r.product_id = p.product_id
GROUP BY p.product_id, p.product_name, c.category_name, p.price, p.stock
ORDER BY units_sold DESC, sales_value DESC;
