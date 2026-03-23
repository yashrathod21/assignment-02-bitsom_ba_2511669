-- ============================================================
-- Part 3 — Analytical Queries (Data Warehouse)
-- File: part3-datawarehouse/dw_queries.sql
-- Schema: fact_sales JOIN dim_date, dim_store, dim_product
-- ============================================================

-- Q1: Total sales revenue by product category for each month
-- Expected output (from retail_transactions.csv, all 300 rows):
--   Jan 2023: Electronics 8,023,049.50 | Grocery 5,574,311.12 | Clothing 2,391,336.40
--   Feb 2023: Electronics 6,120,254.79 | Grocery 1,719,346.65 | Clothing 1,102,957.11
--   ... etc. (12 months x 3 categories)
SELECT
    d.year,
    d.month,
    d.month_name,
    p.category,
    ROUND(SUM(f.total_revenue), 2) AS total_revenue
FROM fact_sales f
JOIN dim_date    d ON f.date_id    = d.date_id
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY d.year, d.month, d.month_name, p.category
ORDER BY d.year, d.month, total_revenue DESC;

-- Q2: Top 2 performing stores by total revenue
-- Expected: Pune FC Road (28,139,086.05) | Chennai Anna (27,889,102.51)
SELECT
    s.store_id,
    s.store_name,
    s.city,
    s.region,
    ROUND(SUM(f.total_revenue), 2) AS total_revenue
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
GROUP BY s.store_id, s.store_name, s.city, s.region
ORDER BY total_revenue DESC
LIMIT 2;

-- Q3: Month-over-month sales trend across all stores
-- Uses LAG window function to compute revenue change and % growth per month
SELECT
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(f.total_revenue), 2)                                          AS monthly_revenue,
    ROUND(
        SUM(f.total_revenue) - LAG(SUM(f.total_revenue))
        OVER (ORDER BY d.year, d.month),
    2)                                                                       AS revenue_change,
    ROUND(
        100.0 *
        (SUM(f.total_revenue) - LAG(SUM(f.total_revenue))
         OVER (ORDER BY d.year, d.month))
        / NULLIF(LAG(SUM(f.total_revenue))
                 OVER (ORDER BY d.year, d.month), 0),
    2)                                                                       AS mom_growth_pct
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
