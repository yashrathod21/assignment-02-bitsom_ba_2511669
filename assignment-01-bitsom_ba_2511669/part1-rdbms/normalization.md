## Anomaly Analysis

The following anomalies were identified in `orders_flat.csv`, which contains 186 rows and 15 columns representing a fully denormalized view of orders, customers, products, and sales representatives.

### Insert Anomaly

**Rows/Columns affected:** `product_id`, `product_name`, `category`, `unit_price` — specifically for any new product with no orders yet.

**Example from data:** Product `P008` (Webcam, Electronics, ₹2,100) appears in exactly one row — `ORD1185`. If the company adds a new product (e.g., a "Projector") before any customer orders it, there is no way to record that product in the system. The flat file stores product data only inside order rows — there is no standalone product record. A valid business entity (a product ready for sale) cannot be inserted until a transaction occurs. This is a textbook insert anomaly.

---

### Update Anomaly

**Rows/Columns affected:** `office_address` column for `sales_rep_id = SR01` (Deepak Joshi).

**Example from data:** Sales rep `SR01` (Deepak Joshi) appears across 83 rows. His office address is stored in two inconsistent forms: 68 rows contain `"Mumbai HQ, Nariman Point, Mumbai - 400021"` while 15 rows — including `ORD1180`, `ORD1173`, `ORD1170`, `ORD1183`, and `ORD1181` — contain the abbreviated `"Mumbai HQ, Nariman Pt, Mumbai - 400021"`. Because the address is repeated in every SR01 row, a single address correction requires updating all 83 rows. Missing even one creates contradictory records for the same representative — and this inconsistency is already present in the dataset.

---

### Delete Anomaly

**Rows/Columns affected:** `customer_name`, `customer_email`, `customer_city` for `customer_id = C007` (Arjun Nair).

**Example from data:** Customer `C007` (Arjun Nair, arjun@gmail.com, Bangalore) has placed 25 orders in the dataset (`ORD1098`, `ORD1093`, `ORD1163`, `ORD1148`, `ORD1049`, and 20 others). All personal information about this customer exists exclusively as repeated values inside those order rows. If all 25 orders were cancelled and deleted for business reasons, every trace of Arjun Nair — name, email, city — would be permanently lost. Deleting order data unintentionally destroys customer identity data: a classic delete anomaly.

---

## Normalization Justification

The argument that a single flat table is "simpler" than a normalized schema collapses as soon as you examine `orders_flat.csv` under real workload conditions.

Consider what the update anomaly already reveals: `orders_flat.csv` currently contains two different office addresses for the same sales representative, `SR01` (Deepak Joshi) — `"Nariman Point"` in 68 rows and `"Nariman Pt"` in 15 rows. This is not a hypothetical risk; it is an actual inconsistency present in the dataset right now, caused precisely by the fact that one logical fact (a rep's address) is stored in 83 redundant places. Any query that filters or groups by office address will silently return wrong results. In a normalized schema, this address lives in exactly one row of a `sales_representatives` table, and updating it requires a single `UPDATE` statement.

The product data tells a similar story. Product `P008` (Webcam, ₹2,100) appears in only one row (`ORD1185`). If that order is deleted due to a return, the product ceases to exist in the database entirely. A product manager running a catalog report will not see the Webcam. In a normalized `products` table, the product exists independently of whether it has been ordered.

Customer data compounds this further. All 25 orders from `C007` (Arjun Nair) carry his name, email, and city in every row. Correcting a typo in his email requires finding and updating all 25 rows consistently — miss one, and two versions of the same customer coexist in the system.

Normalization is not over-engineering — it is the minimum structure needed to prevent data inconsistencies that are already visible in this raw file. The one-time cost of designing five tables is trivial compared to the ongoing cost of debugging stale, contradictory data at scale.
