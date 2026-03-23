-- ============================================================
-- Part 3 — Star Schema Design
-- File: part3-datawarehouse/star_schema.sql
-- Source: retail_transactions.csv (300 rows, cleaned before loading)
-- Stores: Chennai Anna, Delhi South, Bangalore MG, Pune FC Road,
--         Mumbai Central
-- Categories (after cleaning): Electronics, Clothing, Grocery
-- ============================================================

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_product;

-- ============================================================
-- Dimension: dim_date
-- ============================================================
CREATE TABLE dim_date (
    date_id      INT         PRIMARY KEY,  -- YYYYMMDD surrogate key
    full_date    DATE        NOT NULL,
    day          INT         NOT NULL,
    month        INT         NOT NULL,
    month_name   VARCHAR(20) NOT NULL,
    quarter      INT         NOT NULL,
    year         INT         NOT NULL,
    day_of_week  VARCHAR(15) NOT NULL,
    is_weekend   BOOLEAN     NOT NULL
);

-- ============================================================
-- Dimension: dim_store
-- Based on 5 unique stores in retail_transactions.csv
-- NULL city values resolved via store_name lookup (ETL Decision 3)
-- ============================================================
CREATE TABLE dim_store (
    store_id    INT          PRIMARY KEY AUTO_INCREMENT,
    store_name  VARCHAR(100) NOT NULL UNIQUE,
    city        VARCHAR(80)  NOT NULL,
    region      VARCHAR(50)  NOT NULL
);

-- ============================================================
-- Dimension: dim_product
-- Based on unique product_name + category combinations in the data
-- ============================================================
CREATE TABLE dim_product (
    product_id   INT          PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category     VARCHAR(80)  NOT NULL  -- stored in cleaned title-case
);

-- ============================================================
-- Fact Table: fact_sales
-- ============================================================
CREATE TABLE fact_sales (
    sale_id       INT             PRIMARY KEY AUTO_INCREMENT,
    date_id       INT             NOT NULL,
    store_id      INT             NOT NULL,
    product_id    INT             NOT NULL,
    customer_id   VARCHAR(10),
    units_sold    INT             NOT NULL,
    unit_price    DECIMAL(10, 2)  NOT NULL,
    total_revenue DECIMAL(14, 2)  NOT NULL,
    FOREIGN KEY (date_id)    REFERENCES dim_date(date_id),
    FOREIGN KEY (store_id)   REFERENCES dim_store(store_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);

-- ============================================================
-- INSERT: dim_date (dates that appear in the first 10 fact rows)
-- ============================================================
INSERT INTO dim_date (date_id, full_date, day, month, month_name, quarter, year, day_of_week, is_weekend) VALUES
(20230829, '2023-08-29', 29, 8,  'August',    3, 2023, 'Tuesday',   FALSE),
(20231212, '2023-12-12', 12, 12, 'December',  4, 2023, 'Tuesday',   FALSE),
(20230205, '2023-02-05',  5, 2,  'February',  1, 2023, 'Sunday',    TRUE),
(20230220, '2023-02-20', 20, 2,  'February',  1, 2023, 'Monday',    FALSE),
(20230115, '2023-01-15', 15, 1,  'January',   1, 2023, 'Sunday',    TRUE),
(20230809, '2023-08-09',  9, 8,  'August',    3, 2023, 'Wednesday', FALSE),
(20230331, '2023-03-31', 31, 3,  'March',     1, 2023, 'Friday',    FALSE),
(20231026, '2023-10-26', 26, 10, 'October',   4, 2023, 'Thursday',  FALSE),
(20231208, '2023-12-08',  8, 12, 'December',  4, 2023, 'Friday',    FALSE),
(20230815, '2023-08-15', 15, 8,  'August',    3, 2023, 'Tuesday',   FALSE);

-- ============================================================
-- INSERT: dim_store (5 stores, NULL cities resolved by store name)
-- ============================================================
INSERT INTO dim_store (store_name, city, region) VALUES
('Chennai Anna',    'Chennai',   'South'),
('Delhi South',     'Delhi',     'North'),
('Bangalore MG',    'Bangalore', 'South'),
('Pune FC Road',    'Pune',      'West'),
('Mumbai Central',  'Mumbai',    'West');

-- ============================================================
-- INSERT: dim_product (cleaned categories: title-case, Groceries→Grocery)
-- ============================================================
INSERT INTO dim_product (product_name, category) VALUES
('Speaker',     'Electronics'),
('Tablet',      'Electronics'),
('Phone',       'Electronics'),
('Smartwatch',  'Electronics'),
('Headphones',  'Electronics'),
('Laptop',      'Electronics'),
('Jeans',       'Clothing'),
('Jacket',      'Clothing'),
('T-Shirt',     'Clothing'),
('Saree',       'Clothing'),
('Atta 10kg',   'Grocery'),
('Biscuits',    'Grocery'),
('Milk 1L',     'Grocery'),
('Pulses 1kg',  'Grocery'),
('Rice 5kg',    'Grocery'),
('Oil 1L',      'Grocery');

-- ============================================================
-- INSERT: fact_sales (10 rows — cleaned, standardized data)
-- Dates normalized to YYYY-MM-DD, category casing fixed,
-- NULL store_city resolved via store_name mapping
-- ============================================================
INSERT INTO fact_sales (date_id, store_id, product_id, customer_id, units_sold, unit_price, total_revenue) VALUES
(20230829, 1, 1,  'CUST045',  3, 49262.78, 147788.34),  -- TXN5000: Chennai Anna, Speaker
(20231212, 1, 2,  'CUST021', 11, 23226.12, 255487.32),  -- TXN5001: Chennai Anna, Tablet
(20230205, 1, 3,  'CUST019', 20, 48703.39, 974067.80),  -- TXN5002: Chennai Anna, Phone
(20230220, 2, 2,  'CUST007', 14, 23226.12, 325165.68),  -- TXN5003: Delhi South, Tablet
(20230115, 1, 4,  'CUST004', 10, 58851.01, 588510.10),  -- TXN5004: Chennai Anna, Smartwatch
(20230809, 3, 11, 'CUST027', 12, 52464.00, 629568.00),  -- TXN5005: Bangalore MG, Atta 10kg
(20230331, 4, 4,  'CUST025',  6, 58851.01, 353106.06),  -- TXN5006: Pune FC Road, Smartwatch
(20231026, 4, 7,  'CUST041', 16,  2317.47,  37079.52),  -- TXN5007: Pune FC Road, Jeans
(20231208, 3, 12, 'CUST030',  9, 27469.99, 247229.91),  -- TXN5008: Bangalore MG, Biscuits
(20230815, 3, 4,  'CUST020',  3, 58851.01, 176553.03);  -- TXN5009: Bangalore MG, Smartwatch
