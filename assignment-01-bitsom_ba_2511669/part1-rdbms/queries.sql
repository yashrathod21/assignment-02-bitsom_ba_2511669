-- ============================================================
-- Part 1 — SQL Queries
-- File: part1-rdbms/queries.sql
-- All queries run against the normalized schema in schema_design.sql
-- Expected results verified against orders_flat.csv (186 rows)
-- ============================================================

-- Q1: List all customers from Mumbai along with their total order value
-- Expected: Rohan Mehta (C001) = 326,390 | Vikram Singh (C005) = 854,280
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    SUM(oi.quantity * oi.unit_price) AS total_order_value
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
WHERE c.city = 'Mumbai'
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY total_order_value DESC;

-- Q2: Find the top 3 products by total quantity sold
-- Expected: P004 Notebook (91) | P002 Mouse (89) | P007 Pen Set (80)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- Q3: List all sales representatives and the number of unique customers they have handled
-- Expected: SR01 Deepak Joshi = 8 | SR02 Anita Desai = 8 | SR03 Ravi Kumar = 8
SELECT
    r.rep_id,
    r.rep_name,
    COUNT(DISTINCT o.customer_id) AS unique_customers_handled
FROM sales_representatives r
LEFT JOIN orders o ON r.rep_id = o.rep_id
GROUP BY r.rep_id, r.rep_name
ORDER BY unique_customers_handled DESC;

-- Q4: Find all orders where the total value exceeds 10,000, sorted by value descending
-- Expected: 75 such orders; highest = ORD1069/ORD1064/ORD1042/ORD1146 at 275,000
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date,
    SUM(oi.quantity * oi.unit_price) AS total_order_value
FROM orders o
JOIN customers c    ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY o.order_id, c.customer_name, c.city, o.order_date
HAVING SUM(oi.quantity * oi.unit_price) > 10000
ORDER BY total_order_value DESC;

-- Q5: Identify any products that have never been ordered
-- Note: All 8 products in this dataset have been ordered at least once (P008 has 1 order).
-- This query correctly returns an empty result set, which is the right answer for this data.
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;
