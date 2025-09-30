# Data Transformation

## Goal
• Load sample data into RAW on Snowflake, then transform with dbt into a simple Data Vault: hubs, a link, and satellites.

## RAW ingestion (BigQuery ➜ Snowflake)
• **Entry point**: `scripts/04_ingest.sh` → runs `ingest_bq_to_snowflake.py`
• **BigQuery queries** (public dataset `thelook_ecommerce`): 
  - `sql/bq/users.sql`
  - `sql/bq/products.sql` 
  - `sql/bq/order_items.sql`
• **RAW DDL** (Snowflake): `sql/sf/create_raw_tables.sql` → creates `ALLIANZ.RAW.USERS|PRODUCTS|ORDER_ITEMS`
• **Environment**:
  - **GCP ADC**: `gcloud auth application-default login` and set `BQ_BILLING_PROJECT` (US location for this dataset)
  - **Snowflake**: `SF_ACCOUNT`, `SF_USER`, `SF_ROLE`, `SF_WAREHOUSE`, `SF_DATABASE=ALLIANZ`, `SF_SCHEMA_RAW=RAW`
• **Output tables**:
  - `ALLIANZ.RAW.USERS(user_id, first_name, last_name, email, created_at)`
  - `ALLIANZ.RAW.PRODUCTS(product_id, product_name, category, retail_price)`
  - `ALLIANZ.RAW.ORDER_ITEMS(order_item_id, order_id, customer_id, product_id, order_ts, sale_price)`

## STAGING (dbt views)
• **Purpose**: clean types, standardize business keys (BK), add metadata
• **Files**: `dbt/models/staging/`
• **stg_customers.sql**
  - BK: `customer_bk = upper(trim(cast(user_id as string)))`
  - Metadata: `record_source='BQ_USERS'`, `load_dts=current_timestamp()`
• **stg_products.sql**
  - BK: `product_bk = upper(trim(cast(product_id as string)))`
  - Metadata: `record_source='BQ_PRODUCTS'`, `load_dts=current_timestamp()`
• **stg_order_items.sql**
  - BKs: `customer_bk`, `product_bk` from RAW order items
  - Metadata: `record_source='BQ_ORDERS'`, `load_dts=current_timestamp()`
• **Tests** (`schema.yml`): `not_null` on BKs and `load_dts`
• **Materialization**: views into `ALLIANZ.STAGING` (schema pinned by `macros/generate_schema_name.sql`)

## Data Vault (dbt tables)
• **Hash helpers**: `dbt/macros/hash.sql` → `hashkey`, `hashdiff` using `HEX_ENCODE(SHA2(...,256))`

### Hubs (unique BKs)
• **Files**: `dbt/models/dv/hubs/hub_customer.sql`, `hub_product.sql`
• **Keys**: 
  - `h_customer_pk = hashkey(['customer_bk'])`
  - `h_product_pk = hashkey(['product_bk'])`
• **Columns**: hub key, BK, record_source, load_dts
• **Tests**: `unique` + `not_null` on hub keys; `not_null` on BKs

### Link (relationships)
• **File**: `dbt/models/dv/links/lnk_customer_product.sql`
• **Keys**: `l_customer_product_pk = hashkey(['c.h_customer_pk','p.h_product_pk'])`
• **Columns**: `h_customer_pk`, `h_product_pk`, `record_source`, `load_dts`
• **Tests**: `unique` + `not_null` on link key; custom FK tests to hub keys (`tests/generic/fk_ref.sql`)
• **Optional**: incremental materialization with a `where o.load_dts > max(load_dts)` filter

### Satellites (descriptive attributes + change capture)
• **Files**: `dbt/models/dv/sats/sat_customer.sql`, `sat_product.sql`
• **Keys**: `h_*_pk` from hubs; `hashdiff` over descriptive columns
• **Dedup**: `qualify row_number() over (partition by h_*_pk, load_dts order by load_dts) = 1`
• **Tests**: `dbt_utils.unique_combination_of_columns(arguments: [h_*_pk, load_dts])`, `not_null` on keys/hashdiff/load_dts

## Maintainability & efficiency
• **Modularity**: RAW → STAGING → DV; small, readable models with clear BKs and metadata
• **Reuse**: macros for hashing; custom FK test once, reused for both hub references
• **Materializations**: views for staging (cheap); tables for DV (stable); optional incremental link
• **Schema naming**: `generate_schema_name.sql` ensures STAGING and DV are used as-is
• **Observability**: query tagging in profile; engine logs `dbt/logs/dbt.log`; transcripts `logs/build_*.log`

## How to run
• **Load RAW**: `bash scripts/04_ingest.sh`
• **Build staging + DV + tests** (also creates timestamped transcript under `logs/`): `bash scripts/05_dbt.sh`