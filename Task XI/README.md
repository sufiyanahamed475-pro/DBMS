# Task XI - Database Automation Using Views and Procedures

## Objective
Extend the existing `InventoryDB` e-commerce database with reusable views, stored procedures, and a sales calculation function.

## Existing tables used
`Customer`, `Orders`, `Order_Details`, `Product`, `Category`, and `Payment`.

## Implementation
Run `task_11.sql` in MySQL Workbench after Tasks II-VI. The script creates:
- `vw_order_summary` and `vw_product_sales_summary` views
- `fn_order_total(order_id)` sales calculation function
- `sp_refresh_order_total(order_id)` procedure to recalculate an order total
- `sp_set_order_status(order_id, status)` procedure to validate and update order status

## Test
Run the test SELECT statements at the bottom of `task_11.sql`. The script uses existing table and column names and does not recreate the database.
