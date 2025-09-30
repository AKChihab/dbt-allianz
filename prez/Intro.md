Introduction & Approach
Why BigQuery (source)

Public, free & realistic: bigquery-public-data.thelook_ecommerce (users, products, order_items) gives a real retail schema without PII.

Fast sampling: serverless SQL, easy row limits for quick demos.

Low setup friction: works with local ADC (gcloud auth application-default login) and Python’s BigQuery client.

Agenda (flow of the presentation)

Goal & scope (mini Data Vault on Snowflake)

Architecture (RAW → STAGING → DV: hubs, links, satellites)

Environment setup (Snowflake + dbt + Python)

Ingestion demo (BigQuery → Snowflake RAW)

dbt modeling (staging views, hubs/links/sats)

Testing & docs (dbt tests + lineage/docs)

Results & next steps (incremental/historized sats)

Snowflake setup (target)

Account: frfstss-rc57380 (GCP region) with External Browser SSO.

Database: ALLIANZ

Schemas: RAW (landing), STAGING (standardization), DV (Data Vault)

Warehouse/Role: COMPUTE_WH, DEV_ROLE

Key objects:

RAW tables: USERS, PRODUCTS, ORDER_ITEMS

DV tables: hub_customer, hub_product, lnk_customer_product, sat_customer, sat_product

dbt project (transformation & modeling)

Structure

models/staging: stg_customers, stg_products, stg_order_items (views in STAGING)

models/dv/hubs|links|sats: table models in DV

Conventions

Business keys (*_bk), hashed PKs (h_*_pk via HEX_ENCODE(SHA2(...,256))), hashdiffs in satellites, record_source, load_dts.

Tests & docs

Built-ins: not_null, unique, dbt_utils.unique_combination_of_columns

Optional: relationships on link → hubs

Lineage/docs via dbt docs generate

Ingestion pipeline (Python → RAW)

Goal: Pull from BigQuery and load Snowflake RAW.

Steps

Authenticate to BQ: gcloud auth application-default login.

Query BQ: run parameterized SQL (sql/bq/*.sql) for users, products, order_items with row limits.

Preview (optional): print few rows/dtypes for format sanity.

Connect to Snowflake using env vars:

SF_ACCOUNT=frfstss-rc57380, SF_USER, SF_ROLE=DEV_ROLE, SF_WAREHOUSE=COMPUTE_WH, SF_DATABASE=ALLIANZ, SF_SCHEMA_RAW=RAW, authenticator=externalbrowser.

Ensure RAW tables exist: execute sql/sf/create_raw_tables.sql.

Load via write_pandas(...) with overwrite=True (idempotent demo runs).

Exit cleanly: close connection; print total rows loaded.

Run commands

Dry run (no Snowflake load):
bash scripts/04_ingest.sh --dry-run --users-limit 1000 --products-limit 1000 --items-limit 2000

Load RAW + build DV:
bash scripts/04_ingest.sh --users-limit 1000 --products-limit 1000 --items-limit 2000
bash scripts/05_dbt.sh

Architecture at a glance

BigQuery → (Python/ADC) → RAW → (dbt/staging views) → Hubs/Links/Sats (DV)
Tests & Docs via dbt; logs captured under logs/ and dbt/target/.