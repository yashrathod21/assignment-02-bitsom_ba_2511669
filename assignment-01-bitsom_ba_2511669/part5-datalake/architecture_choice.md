## Architecture Recommendation

For a fast-growing food delivery startup collecting GPS location logs, customer text reviews, payment transactions, and restaurant menu images, I would recommend a **Data Lakehouse** architecture.

**Reason 1 — Heterogeneous Data Types That No Single System Handles Well**

The four data types described span the full spectrum of structure: payment transactions are highly structured (tabular, schema-fixed), customer text reviews are semi-structured (variable length, no schema), GPS logs are time-series (high-frequency, append-only), and menu images are unstructured binary blobs. A traditional Data Warehouse (like Redshift or BigQuery) can only ingest structured, pre-cleaned tabular data — it cannot natively store images or raw GPS event streams. A pure Data Lake can store everything but provides no transactional guarantees or query performance for analytics. A Data Lakehouse (built on Delta Lake, Apache Iceberg, or Apache Hudi) combines cheap object storage for all data types with ACID transactions, schema enforcement, and SQL-query performance on top — giving the startup one unified platform instead of three separate systems.

**Reason 2 — Support for Both Streaming and Batch Workloads**

The startup needs real-time access to GPS data (for live driver tracking) as well as batch analytics (e.g., weekly cohort analysis of customer reviews, monthly revenue by restaurant). A Data Warehouse handles batch analytics well but cannot ingest high-frequency streaming data. A pure Data Lake can ingest streams but struggles to serve fast SQL queries on demand. A Lakehouse with a streaming layer (e.g., Apache Kafka feeding Delta Lake) handles both: GPS logs stream in continuously while the analytics and finance teams query clean, versioned tables using Spark SQL or tools like DuckDB — the same engine used in this assignment's Part 5.

**Reason 3 — Cost-Effectiveness at Scale**

GPS logs from thousands of delivery agents generate tens of gigabytes per day. Storing this volume in a columnar managed Data Warehouse would be prohibitively expensive. Object storage (Amazon S3, Google Cloud Storage) underlying a Lakehouse costs a fraction of managed warehouse storage, with no sacrifice in query performance for analytical use cases thanks to columnar file formats like Parquet and ORC — the same format used for `products.parquet` in this dataset. As the startup grows, storage cost scales linearly rather than exponentially, which is critical during the high-growth phase.
