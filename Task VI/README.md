# Task VI - Product Review and Rating Management System

## Objective
Store customer reviews and ratings, retrieve product feedback, calculate average product ratings, and identify highly rated products.

## SQL

```sql
USE InventoryDB;

CREATE TABLE IF NOT EXISTS Review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    review_text VARCHAR(500) NOT NULL,
    review_date DATE NOT NULL,
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    CONSTRAINT fk_review_product FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE IF NOT EXISTS Rating (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating_value INT NOT NULL,
    rating_date DATE NOT NULL,
    CONSTRAINT fk_rating_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    CONSTRAINT fk_rating_product FOREIGN KEY (product_id) REFERENCES Product(product_id),
    CONSTRAINT chk_rating_value CHECK (rating_value BETWEEN 1 AND 5),
    UNIQUE (customer_id, product_id)
);

-- Sample reviews
INSERT INTO Review (customer_id, product_id, review_text, review_date) VALUES
(1, 1, 'Good quality wireless mouse.', '2026-09-02'),
(2, 3, 'Comfortable office chair.', '2026-09-02'),
(3, 5, 'Good rice quality and packaging.', '2026-09-02'),
(1, 2, 'Charger works well.', '2026-09-02');

-- Sample ratings
INSERT INTO Rating (customer_id, product_id, rating_value, rating_date) VALUES
(1, 1, 5, '2026-09-02'),
(2, 3, 4, '2026-09-02'),
(3, 5, 5, '2026-09-02'),
(1, 2, 4, '2026-09-02');

-- 1. Retrieve all product reviews
SELECT
    r.review_id,
    c.customer_name,
    p.product_name,
    r.review_text,
    r.review_date
FROM Review r
JOIN Customer c ON r.customer_id = c.customer_id
JOIN Product p ON r.product_id = p.product_id
ORDER BY r.review_date DESC;

-- 2. Retrieve reviews for a particular product
SELECT
    p.product_name,
    c.customer_name,
    r.review_text,
    r.review_date
FROM Review r
JOIN Product p ON r.product_id = p.product_id
JOIN Customer c ON r.customer_id = c.customer_id
WHERE p.product_id = 1;

-- 3. Calculate average rating for each product
SELECT
    p.product_id,
    p.product_name,
    COUNT(r.rating_id) AS number_of_ratings,
    ROUND(AVG(r.rating_value), 2) AS average_rating
FROM Product p
LEFT JOIN Rating r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
ORDER BY average_rating DESC;

-- 4. Identify highly rated products (average rating >= 4)
SELECT
    p.product_id,
    p.product_name,
    ROUND(AVG(r.rating_value), 2) AS average_rating
FROM Product p
JOIN Rating r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
HAVING AVG(r.rating_value) >= 4
ORDER BY average_rating DESC;

-- 5. Highest-rated products using aggregate functions
SELECT
    p.product_name,
    MAX(r.rating_value) AS highest_rating,
    MIN(r.rating_value) AS lowest_rating,
    ROUND(AVG(r.rating_value), 2) AS average_rating
FROM Product p
JOIN Rating r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
ORDER BY average_rating DESC;

-- 6. Rating distribution
SELECT
    rating_value,
    COUNT(*) AS number_of_customers
FROM Rating
GROUP BY rating_value
ORDER BY rating_value DESC;
```

## Tables Created
- `Review`
- `Rating`

`Review` stores written customer feedback, while `Rating` stores a numeric rating from 1 to 5. Both are connected to the existing `Customer` and `Product` tables.
