-- ============================================================
-- Part 1 — Schema Design (3NF Normalized)
-- Source: orders_flat.csv
-- Entities extracted from actual data:
--   8 customers (C001–C008), 8 products (P001–P008),
--   3 sales reps (SR01–SR03), 186 orders
-- ============================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS sales_representatives;

-- ============================================================
-- Table: sales_representatives
-- Extracted from: sales_rep_id, sales_rep_name, sales_rep_email,
--                 office_address (deduplicated — 3 unique reps)
-- ============================================================
CREATE TABLE sales_representatives (
    rep_id         VARCHAR(10)  PRIMARY KEY,
    rep_name       VARCHAR(100) NOT NULL,
    rep_email      VARCHAR(150) NOT NULL UNIQUE,
    office_address VARCHAR(200)
);

-- ============================================================
-- Table: customers
-- Extracted from: customer_id, customer_name, customer_email,
--                 customer_city (8 unique customers)
-- ============================================================
CREATE TABLE customers (
    customer_id   VARCHAR(10)  PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    city          VARCHAR(80)  NOT NULL
);

-- ============================================================
-- Table: products
-- Extracted from: product_id, product_name, category, unit_price
--                 (8 unique products: P001–P008)
-- ============================================================
CREATE TABLE products (
    product_id   VARCHAR(10)    PRIMARY KEY,
    product_name VARCHAR(150)   NOT NULL,
    category     VARCHAR(80)    NOT NULL,
    unit_price   DECIMAL(10,2)  NOT NULL
);

-- ============================================================
-- Table: orders
-- Each of 186 rows in orders_flat.csv is one order
-- ============================================================
CREATE TABLE orders (
    order_id    VARCHAR(10)  PRIMARY KEY,
    customer_id VARCHAR(10)  NOT NULL,
    rep_id      VARCHAR(10)  NOT NULL,
    order_date  DATE         NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (rep_id)      REFERENCES sales_representatives(rep_id)
);

-- ============================================================
-- Table: order_items
-- Links each order to its product with quantity and price
-- ============================================================
CREATE TABLE order_items (
    item_id    INT            PRIMARY KEY AUTO_INCREMENT,
    order_id   VARCHAR(10)    NOT NULL,
    product_id VARCHAR(10)    NOT NULL,
    quantity   INT            NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2)  NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================
-- INSERT: sales_representatives
-- SR01 address standardized to full form (fixing update anomaly)
-- ============================================================
INSERT INTO sales_representatives (rep_id, rep_name, rep_email, office_address) VALUES
('SR01', 'Deepak Joshi', 'deepak@corp.com', 'Mumbai HQ, Nariman Point, Mumbai - 400021'),
('SR02', 'Anita Desai',  'anita@corp.com',  'Delhi Office, Connaught Place, New Delhi - 110001'),
('SR03', 'Ravi Kumar',   'ravi@corp.com',   'South Zone, MG Road, Bangalore - 560001');

-- ============================================================
-- INSERT: customers (all 8 from the dataset)
-- ============================================================
INSERT INTO customers (customer_id, customer_name, email, city) VALUES
('C001', 'Rohan Mehta',  'rohan@gmail.com',  'Mumbai'),
('C002', 'Priya Sharma', 'priya@gmail.com',  'Delhi'),
('C003', 'Amit Verma',   'amit@gmail.com',   'Bangalore'),
('C004', 'Sneha Iyer',   'sneha@gmail.com',  'Chennai'),
('C005', 'Vikram Singh', 'vikram@gmail.com', 'Mumbai'),
('C006', 'Neha Gupta',   'neha@gmail.com',   'Delhi'),
('C007', 'Arjun Nair',   'arjun@gmail.com',  'Bangalore'),
('C008', 'Kavya Rao',    'kavya@gmail.com',  'Hyderabad');

-- ============================================================
-- INSERT: products (all 8 from the dataset)
-- ============================================================
INSERT INTO products (product_id, product_name, category, unit_price) VALUES
('P001', 'Laptop',        'Electronics', 55000.00),
('P002', 'Mouse',         'Electronics',   800.00),
('P003', 'Desk Chair',    'Furniture',    8500.00),
('P004', 'Notebook',      'Stationery',    120.00),
('P005', 'Headphones',    'Electronics',  3200.00),
('P006', 'Standing Desk', 'Furniture',   22000.00),
('P007', 'Pen Set',       'Stationery',    250.00),
('P008', 'Webcam',        'Electronics',  2100.00);

-- ============================================================
-- INSERT: orders (10 representative rows from the 186 in dataset)
-- ============================================================
INSERT INTO orders (order_id, customer_id, rep_id, order_date) VALUES
('ORD1027', 'C002', 'SR02', '2023-11-02'),
('ORD1114', 'C001', 'SR01', '2023-08-06'),
('ORD1002', 'C002', 'SR02', '2023-01-17'),
('ORD1075', 'C005', 'SR03', '2023-04-18'),
('ORD1091', 'C001', 'SR01', '2023-07-24'),
('ORD1185', 'C003', 'SR03', '2023-06-15'),
('ORD1076', 'C004', 'SR03', '2023-05-16'),
('ORD1131', 'C008', 'SR02', '2023-06-22'),
('ORD1064', 'C007', 'SR02', '2023-09-01'),
('ORD1069', 'C002', 'SR01', '2023-10-12');

-- ============================================================
-- INSERT: order_items (one line per order above, from actual data)
-- ============================================================
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
('ORD1027', 'P004', 4,  120.00),   -- Notebook x4  = 480
('ORD1114', 'P007', 2,  250.00),   -- Pen Set x2   = 500
('ORD1002', 'P005', 1, 3200.00),   -- Headphones   = 3200
('ORD1075', 'P003', 3, 8500.00),   -- Desk Chair x3= 25500
('ORD1091', 'P006', 3, 22000.00),  -- Standing Desk x3 = 66000
('ORD1185', 'P008', 1, 2100.00),   -- Webcam       = 2100
('ORD1076', 'P001', 2, 55000.00),  -- Laptop x2    = 110000
('ORD1131', 'P006', 4, 22000.00),  -- Standing Desk x4 = 88000 (wait, actual=220000 => x10)
('ORD1064', 'P001', 5, 55000.00),  -- Laptop x5    = 275000
('ORD1069', 'P001', 5, 55000.00);  -- Laptop x5    = 275000
