# Task XII - Transaction Management and ACID

## Objective
Demonstrate atomic order processing, stock updates, payment recording, COMMIT, ROLLBACK, and ACID principles using the existing `InventoryDB`.

## Implementation
Run `task_12.sql` in MySQL Workbench. The script includes a transaction template that checks product stock, inserts an order and order details, reduces stock, records a payment, and commits only when all steps succeed. It also demonstrates a safe rollback test.

## Important
Use a test database or sample IDs first. The order procedure is created but is not automatically executed. Replace the sample customer/product IDs and values before calling it.
