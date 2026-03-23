## Storage Systems

The hospital network's four goals require four different storage systems, each chosen for the specific nature of its workload.

**Goal 1 — Predict patient readmission risk** requires a Data Warehouse (Google BigQuery or Snowflake). Historical treatment data — diagnoses, procedures, lab results, discharge summaries — is structured, slowly changing, and must be joined across multiple dimensions (patient, time, department, diagnosis code) for ML feature engineering. A columnar OLAP store is ideal: it supports efficient aggregations over millions of historical records, integrates with ML pipelines (BigQuery ML or Vertex AI), and can be scheduled for nightly batch refresh from the operational system via an ETL/CDC pipeline.

**Goal 2 — Plain-English querying of patient history** requires a Vector Database (Weaviate or Pinecone) combined with a large language model. Clinical notes, discharge summaries, and physician observations are unstructured text. These are chunked and embedded using a medical-domain language model (BioGPT or Med-PaLM), with the resulting vectors stored in the vector DB. When a doctor asks "Has this patient had a cardiac event before?", the query is embedded and a nearest-neighbour search retrieves the semantically closest clinical note chunks, which an LLM then summarizes into a readable answer. This is the RAG (Retrieval-Augmented Generation) pattern.

**Goal 3 — Monthly management reports** (bed occupancy, department-wise costs) reuses the same Data Warehouse as Goal 1, accessed through a BI layer such as Looker or Metabase. Pre-aggregated materialized views and scheduled refreshes ensure dashboards load instantly without touching the operational database.

**Goal 4 — Real-time ICU vitals streaming** requires a Time-Series Database (InfluxDB or TimescaleDB) fronted by Apache Kafka. ICU sensors generate high-frequency numerical data (heart rate, SpO₂, blood pressure sampled every second). A time-series DB provides optimized ingestion and downsampling queries that a general-purpose RDBMS cannot match at this throughput. Kafka decouples the monitoring devices from the storage layer and enables real-time alerting pipelines for critical threshold breaches.

---

## OLTP vs OLAP Boundary

The transactional (OLTP) system is a PostgreSQL database handling all real-time clinical operations: patient admissions, medication administration, appointment scheduling, and billing. It is optimized for row-level reads and writes, strong ACID guarantees, and low-latency responses — properties essential for clinical workflows where a delayed write could mean a missed medication record.

The analytical (OLAP) system is the Data Warehouse. The boundary between the two systems is the **ETL/CDC pipeline** — implemented using Debezium for change-data capture from PostgreSQL — which streams row-level changes into the warehouse in near real-time and transforms them into clean fact and dimension tables.

Doctors and nurses interact exclusively with the OLTP system. Data scientists, finance teams, and hospital administrators interact with the OLAP system through BI dashboards. These two systems never share the same query path, which prevents expensive analytical workloads from degrading the performance of the clinical system that staff depend on for patient care.

---

## Trade-offs

**Trade-off: Data Freshness vs. Operational Isolation**

By separating OLTP and OLAP into distinct systems with an ETL pipeline, the analytical layer is always some hours behind the operational system. A management report generated at 9 AM reflects data up to the previous night's batch run, not that morning's admissions. For monthly reporting this lag is acceptable, but for operational questions like "how many ICU beds are available right now?", it is not.

**Mitigation:** Implement CDC using Debezium to stream row-level changes from PostgreSQL into the Data Warehouse in near real-time (sub-minute latency) rather than overnight batch. For the ICU vitals goal specifically, bypass the warehouse entirely — serve the real-time monitoring dashboard directly from TimescaleDB, which is purpose-built for sub-second time-series queries. This hybrid approach preserves the analytical system's isolation for bulk reporting workloads while providing near-real-time views for the time-critical clinical metrics that cannot tolerate lag.
