# Task V - Payment Transaction Management System

## Objective
Store customer payment transactions, payment mode, date, amount, status, and generate payment analysis and reports.

## SQL

```sql
USE InventoryDB;

CREATE TABLE IF NOT EXISTS Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_mode VARCHAR(30) NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    transaction_reference VARCHAR(100) UNIQUE,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    CONSTRAINT chk_payment_amount CHECK (amount >= 0)
);

-- Sample payment transactions
INSERT INTO Payment
(order_id, payment_mode, payment_date, amount, payment_status, transaction_reference)
VALUES
(1, 'UPI', '2026-09-02', 49.49, 'Successful', 'TXN10001'),
(2, 'Card', '2026-09-02', 149.99, 'Successful', 'TXN10002'),
(3, 'Cash', '2026-09-02', 22.74, 'Failed', 'TXN10003');

-- 1. Insert a new payment
INSERT INTO Payment
(order_id, payment_mode, payment_date, amount, payment_status, transaction_reference)
VALUES
(3, 'UPI', CURRENT_DATE, 22.74, 'Successful', 'TXN10004');

-- 2. Update a failed transaction to successful after confirmation
UPDATE Payment
SET payment_status = 'Successful'
WHERE transaction_reference = 'TXN10003';

-- 3. Successful transactions
SELECT *
FROM Payment
WHERE payment_status = 'Successful';

-- 4. Failed transactions
SELECT *
FROM Payment
WHERE payment_status = 'Failed';

-- 5. Analyze payment methods used by customers
SELECT
    payment_mode,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM Payment
GROUP BY payment_mode
ORDER BY transaction_count DESC;

-- 6. Payment transaction report with customer and order information
SELECT
    p.payment_id,
    c.customer_name,
    p.order_id,
    p.payment_mode,
    p.payment_date,
    p.amount,
    p.payment_status,
    p.transaction_reference
FROM Payment p
JOIN Orders o ON p.order_id = o.order_id
JOIN Customer c ON o.customer_id = c.customer_id
ORDER BY p.payment_date DESC, p.payment_id DESC;

-- 7. Successful vs failed transaction summary
SELECT
    payment_status,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM Payment
GROUP BY payment_status;
```

## Table Created
- `Payment`

The `Payment` table is linked to `Orders` through `order_id`, allowing each payment transaction to be associated with a customer order.
