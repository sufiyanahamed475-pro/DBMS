# Task IV - Order Management System

## Objective
Manage customer orders, order details, quantities, dates, totals, order modification, and customer order history using the existing `InventoryDB` and `Product` table.

## SQL

```sql
USE InventoryDB;

CREATE TABLE IF NOT EXISTS Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    order_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE IF NOT EXISTS Order_Details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    CONSTRAINT fk_order_details_order FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    CONSTRAINT fk_order_details_product FOREIGN KEY (product_id) REFERENCES Product(product_id),
    CONSTRAINT chk_order_quantity CHECK (quantity > 0)
);

-- Sample customers
INSERT INTO Customer (customer_name, email, phone, address) VALUES
('Sufiyan Ahamed', 'sufiyan@example.com', '9094553913', 'Chennai'),
('Janee', 'janee@example.com', '8072129413', 'Chennai'),
('Rahul Kumar', 'rahul@example.com', '9876501234', 'Bengaluru');

-- Sample orders
INSERT INTO Orders (customer_id, order_date, total_amount, order_status) VALUES
(1, '2026-09-02', 49.49, 'Confirmed'),
(2, '2026-09-02', 149.99, 'Pending'),
(3, '2026-09-02', 22.74, 'Confirmed');

-- Order details
INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 19.99),
(1, 2, 1, 29.50),
(2, 3, 1, 149.99),
(3, 5, 1, 12.75),
(3, 6, 1, 9.99);

-- 1. Recalculate order totals from order details
UPDATE Orders o
SET total_amount = (
    SELECT COALESCE(SUM(od.subtotal), 0)
    FROM Order_Details od
    WHERE od.order_id = o.order_id
);

-- 2. Insert a new order
INSERT INTO Orders (customer_id, order_date, total_amount, order_status)
VALUES (1, CURRENT_DATE, 0.00, 'Pending');

-- Add products to the newly inserted order
INSERT INTO Order_Details (order_id, product_id, quantity, unit_price)
VALUES (LAST_INSERT_ID(), 1, 2, 19.99);

-- 3. Modify order quantity
UPDATE Order_Details
SET quantity = 3
WHERE order_detail_id = 1;

-- Update corresponding order total after modification
UPDATE Orders o
SET total_amount = (
    SELECT COALESCE(SUM(od.subtotal), 0)
    FROM Order_Details od
    WHERE od.order_id = o.order_id
)
WHERE o.order_id = 1;

-- 4. Customer order history
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    od.quantity,
    od.unit_price,
    od.subtotal,
    o.total_amount,
    o.order_status
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Details od ON o.order_id = od.order_id
JOIN Product p ON od.product_id = p.product_id
ORDER BY c.customer_id, o.order_date DESC, o.order_id;

-- 5. Total orders and spending by customer
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM Customer c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

-- 6. Individual order report
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total_amount,
    o.order_status
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;
```

## Tables Created
- `Customer`
- `Orders`
- `Order_Details`

`Orders` stores the main order information, while `Order_Details` stores the products and quantities belonging to each order.
