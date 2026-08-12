# Task II

```sql
-- CREATE DATABASE InventoryDB;
-- USE InventoryDB;

-- CREATE TABLE Category (
--     category_id INT AUTO_INCREMENT PRIMARY KEY,
--     category_name VARCHAR(100) UNIQUE NOT NULL,
--     description VARCHAR(255)
-- );

-- CREATE TABLE Product (
--     product_id INT AUTO_INCREMENT PRIMARY KEY,
--     product_name VARCHAR(150) NOT NULL,
--     category_id INT NOT NULL,
--     price DECIMAL(10,2) NOT NULL,
--     stock INT DEFAULT 0 NOT NULL,
--     CONSTRAINT fk_product_category
--         FOREIGN KEY (category_id)
--         REFERENCES Category(category_id)
-- );

-- Insert into Category (category_id is AUTO_INCREMENT, so omit it)
INSERT INTO Category (category_name, description)
VALUES
  ('Electronics', 'Devices, gadgets, and accessories'),
  ('Furniture', 'Home and office furniture'),
  ('Groceries', 'Food and daily essentials');

-- Insert into Product (product_id is AUTO_INCREMENT, so omit it)
-- NOTE: category_id must match existing Category.category_id values
INSERT INTO Product (product_name, category_id, price, stock)
VALUES
  ('Wireless Mouse', 1, 19.99, 120),
  ('USB-C Charger', 1, 29.50, 60),
  ('Office Chair', 2, 149.99, 15),
  ('Dining Table', 2, 399.00, 5),
  ('Basmati Rice 5kg', 3, 12.75, 40),
  ('Olive Oil 1L', 3, 9.99, 25);
  
  
  
  USE InventoryDB;

-- 1) Insert categories first (safe if you run it multiple times)
INSERT INTO Category (category_name, description)
VALUES
  ('Electronics', 'Devices, gadgets, and accessories'),
  ('Furniture',   'Home and office furniture'),
  ('Groceries',   'Food and daily essentials')
ON DUPLICATE KEY UPDATE
  description = VALUES(description);

-- 2) Insert products using category_name -> category_id lookup
INSERT INTO Product (product_name, category_id, price, stock)
VALUES
  ('Wireless Mouse',     (SELECT category_id FROM Category WHERE category_name='Electronics'), 19.99, 120),
  ('USB-C Charger',      (SELECT category_id FROM Category WHERE category_name='Electronics'), 29.50, 60),
  ('Office Chair',       (SELECT category_id FROM Category WHERE category_name='Furniture'),   149.99, 15),
  ('Dining Table',       (SELECT category_id FROM Category WHERE category_name='Furniture'),   399.00, 5),
  ('Basmati Rice 5kg',   (SELECT category_id FROM Category WHERE category_name='Groceries'),   12.75, 40),
  ('Olive Oil 1L',       (SELECT category_id FROM Category WHERE category_name='Groceries'),   9.99, 25);
  
  
  
  USE inventorydb;
  
  
  SELECT category_id, category_name
FROM Category;

INSERT INTO Category (category_name, description)
VALUES
  ('Electronics', 'Devices, gadgets, and accessories'),
  ('Furniture',   'Home and office furniture'),
  ('Groceries',   'Food and daily essentials');
  
  
  SELECT category_id, category_name
FROM Category;


INSERT INTO Product (product_name, category_id, price, stock)
SELECT p.product_name, c.category_id, p.price, p.stock
FROM (
  SELECT 'Wireless Mouse'   AS product_name, 'Electronics' AS category_name, 19.99 AS price, 120 AS stock
  UNION ALL SELECT 'USB-C Charger',      'Electronics', 29.50, 60
  UNION ALL SELECT 'Office Chair',       'Furniture',   149.99, 15
  UNION ALL SELECT 'Dining Table',       'Furniture',   399.00, 5
  UNION ALL SELECT 'Basmati Rice 5kg',   'Groceries',   12.75, 40
  UNION ALL SELECT 'Olive Oil 1L',       'Groceries',   9.99, 25
) p
JOIN Category c
  ON c.category_name = p.category_name;
  
  
  SELECT p.product_id, p.product_name, c.category_name, p.price, p.stock
FROM Product p
JOIN Category c ON c.category_id = p.category_id;


SELECT DATABASE();
SELECT * FROM PRODUCT;
```
