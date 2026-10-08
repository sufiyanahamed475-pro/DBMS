USE InventoryDB;

-- ============================================================
-- TASK X: ADVANCED SQL QUERY SYSTEM
-- ============================================================

-- 1. Subquery: products priced above the average product price
SELECT
    product_id,
    product_name,
    price
FROM Product
WHERE price > (
    SELECT AVG(price)
    FROM Product
)
ORDER BY price DESC;

-- 2. Nested query: customers whose total purchases are above
-- the average customer purchase amount
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(o.total_amount), 2) AS total_purchase
FROM Customer c
JOIN Orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.total_amount) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT
            customer_id,
            SUM(total_amount) AS customer_total
        FROM Orders
        GROUP BY customer_id
    ) AS customer_summary
)
ORDER BY total_purchase DESC;

-- 3. Identify customer(s) with maximum purchases
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(o.total_amount), 2) AS total_purchase
FROM Customer c
JOIN Orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.total_amount) = (
    SELECT MAX(customer_total)
    FROM (
        SELECT
            customer_id,
            SUM(total_amount) AS customer_total
        FROM Orders
        GROUP BY customer_id
    ) AS customer_totals
);

-- 4. Find the most expensive product using a subquery
SELECT
    product_id,
    product_name,
    price
FROM Product
WHERE price = (
    SELECT MAX(price)
    FROM Product
);

-- 5. Find products that have a price greater than their
-- category's average price
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price
FROM Product p
JOIN Category c
    ON p.category_id = c.category_id
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM Product p2
    WHERE p2.category_id = p.category_id
)
ORDER BY c.category_name, p.price DESC;

-- 6. Find customers who placed orders above the average order value
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM Customer c
JOIN Orders o
    ON c.customer_id = o.customer_id
WHERE o.total_amount > (
    SELECT AVG(total_amount)
    FROM Orders
)
ORDER BY c.customer_name;

-- 7. Complex business query:
-- Find the best-selling product in terms of quantity sold
SELECT
    p.product_id,
    p.product_name,
    SUM(od.quantity) AS quantity_sold
FROM Product p
JOIN Order_Details od
    ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(od.quantity) = (
    SELECT MAX(product_quantity)
    FROM (
        SELECT SUM(quantity) AS product_quantity
        FROM Order_Details
        GROUP BY product_id
    ) AS product_sales
);

-- 8. Complex business query:
-- Find the category generating the highest sales
SELECT
    c.category_id,
    c.category_name,
    ROUND(SUM(od.subtotal), 2) AS category_sales
FROM Category c
JOIN Product p
    ON c.category_id = p.category_id
JOIN Order_Details od
    ON p.product_id = od.product_id
GROUP BY c.category_id, c.category_name
HAVING SUM(od.subtotal) = (
    SELECT MAX(category_total)
    FROM (
        SELECT SUM(od2.subtotal) AS category_total
        FROM Product p2
        JOIN Order_Details od2
            ON p2.product_id = od2.product_id
        GROUP BY p2.category_id
    ) AS category_summary
);

-- 9. Advanced SQL report:
-- Customer ranking by total purchase amount
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS total_purchase
FROM Customer c
JOIN Orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_purchase DESC;

-- 10. Advanced SQL report:
-- Products above the overall average price with category details
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    ROUND((SELECT AVG(price) FROM Product), 2) AS overall_average_price
FROM Product p
JOIN Category c
    ON p.category_id = c.category_id
WHERE p.price > (SELECT AVG(price) FROM Product)
ORDER BY p.price DESC;
