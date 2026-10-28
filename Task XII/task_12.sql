USE InventoryDB;

-- TASK XII: TRANSACTION MANAGEMENT AND ACID
-- MySQL 8.0+. InnoDB tables are required for transactional rollback.
-- This procedure creates one order line, updates stock, and records payment atomically.

DROP PROCEDURE IF EXISTS sp_place_order;

DELIMITER $$

CREATE PROCEDURE sp_place_order(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_payment_mode VARCHAR(30),
    IN p_transaction_reference VARCHAR(100)
)
BEGIN
    DECLARE v_stock INT DEFAULT NULL;
    DECLARE v_price DECIMAL(10,2) DEFAULT NULL;
    DECLARE v_order_id INT;
    DECLARE v_total DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Customer WHERE customer_id = p_customer_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer does not exist';
    END IF;

    SELECT stock, price INTO v_stock, v_price
      FROM Product
     WHERE product_id = p_product_id
     FOR UPDATE;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product does not exist';
    END IF;

    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    SET v_total = v_price * p_quantity;

    INSERT INTO Orders (customer_id, order_date, total_amount, order_status)
    VALUES (p_customer_id, CURRENT_DATE, v_total, 'Confirmed');

    SET v_order_id = LAST_INSERT_ID();

    INSERT INTO Order_Details (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, p_product_id, p_quantity, v_price);

    UPDATE Product
       SET stock = stock - p_quantity
     WHERE product_id = p_product_id;

    INSERT INTO Payment
        (order_id, payment_mode, payment_date, amount, payment_status, transaction_reference)
    VALUES
        (v_order_id, p_payment_mode, CURRENT_DATE, v_total, 'Successful', p_transaction_reference);

    COMMIT;

    SELECT v_order_id AS order_id, v_total AS order_total,
           'Committed successfully' AS transaction_result;
END$$

DELIMITER ;

-- TEST: check IDs, stock, and use a unique transaction reference before running.
-- CALL sp_place_order(1, 1, 1, 'UPI', 'TASK12-TEST-001');

-- Demonstrate ROLLBACK without changing persistent data.
START TRANSACTION;
UPDATE Product SET stock = stock WHERE product_id = -1;
ROLLBACK;

-- ACID check: confirm order totals match detail totals.
SELECT o.order_id, o.total_amount,
       COALESCE(SUM(od.subtotal), 0) AS detail_total,
       CASE WHEN o.total_amount = COALESCE(SUM(od.subtotal), 0)
            THEN 'CONSISTENT' ELSE 'CHECK REQUIRED' END AS consistency_check
FROM Orders o
LEFT JOIN Order_Details od ON od.order_id = o.order_id
GROUP BY o.order_id, o.total_amount
ORDER BY o.order_id;
