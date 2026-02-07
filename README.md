# Hevo Assessment II - Messy E-Commerce Orders

This repository contains the deliverables for **Hevo Assessment II**, focusing on cleaning and transforming raw e-commerce data from PostgreSQL to Snowflake using Hevo Models.

---

## Steps to Reproduce

### 1. Set Up PostgreSQL Locally
- Install Docker if not already installed.  
- Run a PostgreSQL container:

```bash
docker run --name hevo-postgres \
  -e POSTGRES_USER=your_user \
  -e POSTGRES_PASSWORD=your_password \
  -e POSTGRES_DB=your_db_name \
  -p 5432:5432 \
  -d postgres
```

#### Enable Logical Replication
1. Access the container:

```bash
docker exec -it hevo-postgres bash
```

2. Edit `postgresql.conf` (typically at `/var/lib/postgresql/data/`) and add:

```bash
wal_level = logical
max_replication_slots = 4
max_wal_senders = 4
```

3. Restart the container:

```bash
docker restart hevo-postgres
```

- Expose the local DB to Hevo using ngrok:

```bash
./ngrok tcp 5432
```

- Execute `sql/postgres_ddl.sql` to create and load tables.

---

### 2. Set Up Hevo Pipeline
- Sign up for a Snowflake trial and connect via Hevo Free Trial.  
- Create a pipeline in Hevo:
  - **Source:** PostgreSQL (via ngrok URL)
  - **Destination:** Snowflake
  - **Ingestion Mode:** Logical Replication  
- Sync the pipeline to load `customers_raw`, `orders_raw`, `products_raw`, and `country_dim`.

---

### 3. Apply Transformations
- Create Hevo Models using SQL in `sql/transformations.sql` to generate:  
  `CLEANED_CUSTOMERS`, `CLEANED_ORDERS`, `CLEANED_PRODUCTS`, `CLEANED_FINAL_DATA`.
- Test each model in Hevo UI and save.

---

### 4. Validate in Snowflake
- Run queries in `sql/validation.sql` to verify row counts and data integrity.

---

### 5. Record Loom Video
- Record setup, pipeline sync, model creation/testing, and validation.  
- Upload and note the link in `loom_link.txt`.

---

## Assumptions Made
- **Data Types:** `customer_id` as INTEGER, `email`/`phone` as TEXT, `amount` as FLOAT, `created_at`/`updated_at` as TIMESTAMP.  
- **Country Codes:** Standardized via `country_dim`; unmatched codes → `'Unknown'`.  
- **Phone Format:** Non-standard or missing phones → `'Unknown'`.  
- **Currency Conversion:** Hardcoded rates: INR → 0.012, SGD → 0.75, EUR → 1.1 (USD = 1).  
- **Null Handling:** `created_at` null → `'1900-01-01'`; null/negative `amount` → 0.

---

## Postgres → Hevo Connection
- PostgreSQL running in Docker on `localhost:5432`.  
- Exposed via ngrok for Hevo connection.  
- Logical replication enabled for real-time ingestion.

---

## Choices for Transformations
- **Deduplication:** `ROW_NUMBER()` for customers/orders to keep latest records.  
- **Standardization:** Emails lowercased, phones regex-cleaned, currencies uppercased, product/category names capitalized.  
- **Edge Cases:** Null customers → `'Invalid Customer'`, missing customers → `'Orphan Customer'`, inactive/missing products → `'Unknown Product'`.  
- **Joins:** `LEFT JOIN` retains all orders even if customer or product data is missing.

---

## Issues / Workarounds
- **Duplicate Ingestion:** Repeated historical reloads caused duplicate rows in Snowflake for `customers_raw` table; paused pipeline, dropped the table, cleared pending events and restarted historical reload after clearing duplicates.  
- **Schema Mapping Issue:** Initially Primary Key was set for `customers_raw` table so Hevo removed duplicate rows while ingesting raw data; resolved by resetting schema mapping in Hevo and restarted full historical reload for table. Then, raw data was ingested without removing duplicates.  
- **Ngrok Port Change:** Restarting ngrok gave a new port; manually updated Hevo source and resynced. 

---

## Files
- `sql/postgres_ddl.sql` — DDL and inserts for Postgres tables.  
- `sql/transformations.sql` — SQL for Hevo Models.  
- `sql/validation.sql` — Validation queries.  
- `csv_data/` — Placeholder for CSV files.  

---

## Deliverables
- **GitHub Repo Link:** 
- **Hevo Details:**  
  - Name: Varsha Singh  
  - Pipeline ID: 1  
  - Model Numbers: 1, 2, 3 & 4  
- **Loom Video Link:** https://www.loom.com/share/348229b688b54ece9778e6a6fe7805f0
