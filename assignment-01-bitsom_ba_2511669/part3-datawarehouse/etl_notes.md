## ETL Decisions

### Decision 1 — Standardizing Three Mixed Date Formats

**Problem:** The `date` column in `retail_transactions.csv` contains dates in three different formats across the 300 rows: `DD/MM/YYYY` (e.g., `29/08/2023` — found in 105 rows), `DD-MM-YYYY` (e.g., `12-12-2023` — found in 83 rows), and `YYYY-MM-DD` (e.g., `2023-02-05` — found in 112 rows). Loading these raw values into a DATE column causes type errors or silent mis-parses. For example, `05/03/2023` could be read as 5th March or 3rd May depending on which parser runs first, corrupting all month-level aggregations in the warehouse.

**Resolution:** During the ETL transformation step, a format-detection function was applied to every date value, trying each of the three patterns in sequence (`%d/%m/%Y`, `%d-%m-%Y`, `%Y-%m-%d`) until one parsed successfully. All dates were then uniformly stored as ISO 8601 `YYYY-MM-DD` in `dim_date`. A surrogate integer key in `YYYYMMDD` format (e.g., `20230829`) was generated for efficient joining in `fact_sales`. Rows where the date could not be parsed by any of the three formats were flagged for manual review and excluded from the initial load.

---

### Decision 2 — Normalizing Inconsistent Category Casing

**Problem:** The `category` column contains the same categories in multiple casing variants across the 300 rows. Specifically: `"Electronics"` (60 rows) and `"electronics"` (41 rows) represent the same category; similarly, `"Grocery"` (87 rows) and `"Groceries"` (40 rows) represent the same category. A simple `GROUP BY category` produces five groups instead of three, incorrectly splitting Electronics into two buckets and Grocery into two buckets — inflating category counts and breaking all revenue-by-category reports.

**Resolution:** All category values were transformed using `TRIM(INITCAP(value))` to strip whitespace and apply title case, producing `"Electronics"`, `"Clothing"`, and `"Grocery"` as the canonical set. The variant `"Groceries"` was additionally mapped to `"Grocery"` via an explicit replacement rule before loading into `dim_product`. The three canonical values were defined as a controlled vocabulary; any value not in this set would raise a validation error during the ETL run rather than being silently inserted.

---

### Decision 3 — Resolving 19 NULL Values in the store_city Column

**Problem:** 19 out of 300 rows in `retail_transactions.csv` have a NULL value in the `store_city` column. The affected rows span all five stores: `Mumbai Central` (3 NULL rows), `Chennai Anna` (4 rows), `Delhi South` (5 rows), `Pune FC Road` (6 rows), and `Bangalore MG` (1 row). Inserting these rows as-is would either fail a NOT NULL constraint on `dim_store.city` or require creating duplicate store records — one with a city and one without — which would cause double-counting in store-level revenue queries.

**Resolution:** Since `store_name` is always populated and each store name maps to exactly one city (verified by cross-referencing all non-NULL rows), the city was imputed deterministically from the store name via a lookup: `Chennai Anna → Chennai`, `Delhi South → Delhi`, `Bangalore MG → Bangalore`, `Pune FC Road → Pune`, `Mumbai Central → Mumbai`. This guaranteed that all 300 rows loaded into `fact_sales` with a valid `store_id` foreign key, and `dim_store` remains a clean five-row dimension with no duplicate entries.
