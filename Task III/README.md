# Task III - Seller and Inventory Management System

## Objective
Manage sellers, seller products, stock availability, and inventory status reports using the existing `InventoryDB` and `Product` table from Task II.

## SQL

```sql
USE InventoryDB;

-- Seller table
CREATE TABLE IF NOT EXISTS Seller (
    seller_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(255)
);

-- Seller_Product keeps seller-specific product information.
CREATE TABLE IF NOT EXISTS Seller_Product (
    seller_product_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    product_id INT NOT NULL,
    seller_price DECIMAL(10,2) NOT NULL,
    added_date DATE NOT NULL,
    UNIQUE (seller_id, product_id),
    CONSTRAINT fk_sp_seller FOREIGN KEY (seller_id) REFERENCES Seller(seller_id),
    CONSTRAINT fk_sp_product FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Inventory tracks stock supplied by each seller.
CREATE TABLE IF NOT EXISTS Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    product_id INT NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    last_updated DATE NOT NULL,
    CONSTRAINT fk_inventory_seller FOREIGN KEY (seller_id) REFERENCES Seller(seller_id),
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES Product(product_id),
    CONSTRAINT chk_inventory_stock CHECK (stock_quantity >= 0),
    UNIQUE (seller_id, product_id)
);

-- Sample sellers
INSERT INTO Seller (seller_name, email, phone, address) VALUES
('Tech World', 'techworld@example.com', '9876543210', 'Chennai'),
('Home Store', 'homestore@example.com', '9876543211', 'Chennai'),
('Fresh Mart', 'freshmart@example.com', '9876543212', 'Chennai');

-- Seller product information
INSERT INTO Seller_Product (seller_id, product_id, seller_price, added_date) VALUES
(1, 1, 18.50, '2026-09-02'),
(1, 2, 28.00, '2026-09-02'),
(2, 3, 145.00, '2026-09-02'),
(2, 4, 385.00, '2026-09-02'),
(3, 5, 11.75, '2026-09-02'),
(3, 6, 9.25, '2026-09-02');

-- Inventory data
INSERT INTO Inventory (seller_id, product_id, stock_quantity, last_updated) VALUES
(1, 1, 50, '2026-09-02'),
(1, 2, 30, '2026-09-02'),
(2, 3, 10, '2026-09-02'),
(2, 4, 0, '2026-09-02'),
(3, 5, 25, '2026-09-02'),
(3, 6, 0, '2026-09-02');

-- 1. Update stock
UPDATE Inventory
SET stock_quantity = 35, last_updated = CURRENT_DATE
WHERE inventory_id = 1;

-- 2. Available products
SELECT i.inventory_id, s.seller_name, p.product_name, i.stock_quantity
FROM Inventory i
JOIN Seller s ON i.seller_id = s.seller_id
JOIN Product p ON i.product_id = p.product_id
WHERE i.stock_quantity > 0;

-- 3. Unavailable products
SELECT i.inventory_id, s.seller_name, p.product_name, i.stock_quantity
FROM Inventory i
JOIN Seller s ON i.seller_id = s.seller_id
JOIN Product p ON i.product_id = p.product_id
WHERE i.stock_quantity = 0;

-- 4. Inventory status report
SELECT
    i.inventory_id,
    s.seller_name,
    p.product_name,
    i.stock_quantity,
    CASE
        WHEN i.stock_quantity > 0 THEN 'Available'
        ELSE 'Unavailable'
    END AS inventory_status,
    i.last_updated
FROM Inventory i
JOIN Seller s ON i.seller_id = s.seller_id
JOIN Product p ON i.product_id = p.product_id
ORDER BY s.seller_name, p.product_name;

-- 5. Total stock supplied by each seller
SELECT s.seller_id, s.seller_name, SUM(i.stock_quantity) AS total_stock
FROM Seller s
JOIN Inventory i ON s.seller_id = i.seller_id
GROUP BY s.seller_id, s.seller_name;
```

## Tables Created
- `Seller`
- `Seller_Product`
- `Inventory`

`Seller_Product` connects sellers with products, while `Inventory` tracks the stock quantity for each seller-product combination.
