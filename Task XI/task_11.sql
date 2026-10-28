USE InventoryDB;

-- TASK XI: DATABASE AUTOMATION USING VIEWS AND PROCEDURES
-- MySQL 8.0+; uses the existing InventoryDB schema.

CREATE OR REPLACE VIEW vw_order_summary AS
SELECT o.order_id, o.order_date, o.order_status,
       c.customer_id, c.customer_name, c.email,
       o.total_amount,
       COALESCE(SUM(od.quantity), 0) AS total_units
FROM Orders o
JOIN Customer c ON c.customer_id = o.customer_id
LEFT JOIN Order_Details od ON od.order_id = o.order_id
GROUP BY o.order_id, o.order_date, o.order_status,
         c.customer_id, c.customer_name, c.email, o.total_amount;

CREATE OR REPLACE VIEW vw_product_sales_summary AS
SELECT p.product_id, p.product_name, c.category_name, p.price,
       p.stock, COALESCE(SUM(od.quantity), 0) AS units_sold,
       COALESCE(ROUND(SUM(od.subtotal), 2), 0.00) AS sales_value
FROM Product p
JOIN Category c ON c.category_id = p.category_id
LEFT JOIN Order_Details od ON od.product_id = p.product_id
GROUP BY p.product_id, p.product_name, c.category_name, p.price, p.stock;

DROP FUNCTION IF EXISTS fn_order_total;
DROP PROCEDURE IF EXISTS sp_refresh_order_total;
DROP PROCEDURE IF EXISTS sp_set_order_status;

DELIMITER $$

CREATE FUNCTION fn_order_total(p_order_id INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT COALESCE(SUM(subtotal), 0.00)
      INTO v_total
      FROM Order_Details
     WHERE order_id = p_order_id;
    RETURN v_total;
END$$

CREATE PROCEDURE sp_refresh_order_total(IN p_order_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order ID does not exist';
    END IF;

    UPDATE Orders
       SET total_amount = fn_order_total(p_order_id)
     WHERE order_id = p_order_id;

    SELECT order_id, total_amount
      FROM Orders
     WHERE order_id = p_order_id;
END$$

CREATE PROCEDURE sp_set_order_status(
    IN p_order_id INT,
    IN p_status VARCHAR(30)
)
BEGIN
    IF p_status NOT IN ('Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid order status';
    END IF;

    UPDATE Orders
       SET order_status = p_status
     WHERE order_id = p_order_id;

    IF ROW_COUNT() = 0 AND NOT EXISTS
       (SELECT 1 FROM Orders WHERE order_id = p_order_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order ID does not exist';
    END IF;
END$$

DELIMITER ;

-- TEST VIEWS
SELECT * FROM vw_order_summary ORDER BY order_id;
SELECT * FROM vw_product_sales_summary ORDER BY sales_value DESC;

-- TEST FUNCTION (replace 1 with an existing order_id)
SELECT fn_order_total(1) AS calculated_order_total;

-- TEST PROCEDURE (replace 1 with an existing order_id)
CALL sp_refresh_order_total(1);
CALL sp_set_order_status(1, 'Confirmed');
SELECT order_id, order_status, total_amount FROM Orders WHERE order_id = 1;
