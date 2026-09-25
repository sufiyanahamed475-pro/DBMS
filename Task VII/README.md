# Task VII - SQL Query Implementation for E-Commerce Database

## Objective

Perform SQL query implementation for the existing `InventoryDB` e-commerce database using `Category`, `Product`, `Customer`, `Orders`, `Order_Details`, `Payment`, `Review`, and `Rating` tables created in previous tasks.

## Requirements Covered

1. Perform SELECT, WHERE, ORDER BY, and DISTINCT queries.
2. Search products based on price, category, and availability.
3. Retrieve customer and product information.
4. Apply filtering conditions.
5. Generate basic business reports.

## SQL File

The complete implementation is available in [task_7.sql](./task_7.sql).

## Main Query Areas

### 1. Basic SELECT Queries
- Display all products.
- Display selected product columns.
- Sort products by price.

### 2. Filtering Queries
- Products below a selected price.
- Products within a price range.
- Available products using stock quantity.
- Products from a selected category.

### 3. DISTINCT Queries
- List unique product categories.
- List unique order statuses.
- List unique payment modes.

### 4. Customer and Product Information
- Retrieve customer order history.
- Display products purchased by customers.
- Combine product and category information.

### 5. Business Reports
- Product count and average price by category.
- Inventory stock report.
- Total orders and revenue by customer.
- Payment status summary.
- Top-selling products based on quantity ordered.
- Product rating summary.

## Database

`InventoryDB` is used throughout the implementation.

## Tables Used

- `Category`
- `Product`
- `Customer`
- `Orders`
- `Order_Details`
- `Payment`
- `Review`
- `Rating`

## Outcome

This task demonstrates practical SQL querying, filtering, sorting, joins, DISTINCT, aggregate functions, GROUP BY, HAVING, and basic business reporting for an e-commerce database.
