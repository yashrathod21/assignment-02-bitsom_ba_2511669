-- ============================================================
-- Part 5 — Data Lake & DuckDB Queries
-- File: part5-datalake/duckdb_queries.sql
--
-- Files read directly (no pre-loading):
--   customers.csv  → columns: customer_id, name, city, signup_date, email
--   orders.json    → columns: order_id, customer_id, order_date, status,
--                              total_amount, num_items
--   products.parquet → columns: line_item_id, order_id, product_id,
--                                product_name, category, quantity,
--                                unit_price, total_price
--
-- Join keys:
--   customers ↔ orders    : customer_id
--   orders    ↔ products  : order_id
--
-- Run from the repo root:
--   duckdb -c ".read part5-datalake/duckdb_queries.sql"
-- ============================================================

-- Q1: List all customers along with the total number of orders they have placed
-- Expected top result: CUST025 Aarav Desai, CUST004 Neha Joshi, CUST048 Suresh Menon
SELECT
    c.customer_id,
    c.name            AS customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders
FROM read_csv_auto('datasets/customers.csv')     AS c
LEFT JOIN read_json_auto('datasets/orders.json') AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city
ORDER BY total_orders DESC;

-- Q2: Find the top 3 customers by total order value
-- Expected: CUST025 Aarav Desai (50331) | CUST004 Neha Joshi (45527) |
--           CUST048 Suresh Menon (40629)
SELECT
    c.customer_id,
    c.name                        AS customer_name,
    c.city,
    SUM(o.total_amount)           AS total_order_value
FROM read_csv_auto('datasets/customers.csv')     AS c
JOIN read_json_auto('datasets/orders.json')      AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city
ORDER BY total_order_value DESC
LIMIT 3;

-- Q3: List all products purchased by customers from Bangalore
-- Joins customers → orders → products (via order_id in products.parquet)
-- Expected customers from Bangalore: CUST018 Neha Shah, CUST022 Divya Patel,
--   CUST031 Rohan Pillai, CUST045 Aarav Sharma, CUST050 Sneha Mehta
SELECT DISTINCT
    p.product_id,
    p.product_name,
    p.category
FROM read_csv_auto('datasets/customers.csv')       AS c
JOIN read_json_auto('datasets/orders.json')        AS o
    ON c.customer_id = o.customer_id
JOIN read_parquet('datasets/products.parquet')     AS p
    ON o.order_id    = p.order_id
WHERE LOWER(TRIM(c.city)) = 'bangalore'
ORDER BY p.category, p.product_name;

-- Q4: Join all three files to show: customer name, order date, product name, and quantity
SELECT
    c.name           AS customer_name,
    o.order_date,
    p.product_name,
    p.quantity
FROM read_csv_auto('datasets/customers.csv')       AS c
JOIN read_json_auto('datasets/orders.json')        AS o
    ON c.customer_id = o.customer_id
JOIN read_parquet('datasets/products.parquet')     AS p
    ON o.order_id    = p.order_id
ORDER BY o.order_date DESC, c.name;
