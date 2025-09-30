## Goal

Stand up a Data Vault 2.0 slice on Snowflake using dbt, fed from an open BigQuery dataset, with clean layering, tested models, and reproducible execution.

## Source & Layers

### Source system
• BigQuery `bigquery-public-data.thelook_ecommerce` (users, products, orders/items)

### Snowflake layers (schemas)
• **RAW**: landing of source tables 1:1 (USERS, PRODUCTS, ORDER_ITEMS). No transforms.
• **DV**: Data Vault core (Hubs, Links, Satellites) built from STAGING views.
• **STAGING** (dbt views in DV schema for simplicity): light standardization (trim/upper BKs, load_dts, record_source).

### Why this split?
• **RAW** = auditability and replay
• **STAGING** = deterministic, source-specific cleanup
• **DV** = enterprise keys & historization (PK hash keys, link grain, satellite hashdiffs)

## Model Inventory (meets "2 hubs + 1 link + satellites")

### Hubs
• **hub_customer**: 
  - BK = customer_bk (from users.user_id)
  - h_customer_pk = UPPER(HEX_ENCODE(SHA2(customer_bk, 256)))

• **hub_product**: 
  - BK = product_bk (from products.id)
  - h_product_pk = UPPER(HEX_ENCODE(SHA2(product_bk, 256)))

### Link
• **lnk_customer_product**: 
  - connects hub_customer ↔ hub_product via orders
  - l_customer_product_pk = HEX_ENCODE(SHA2(h_customer_pk || '||' || h_product_pk, 256))

### Satellites
• **sat_customer**: 
  - attributes: first_name, last_name, email, created_at
  - customer_hashdiff = HEX_ENCODE(SHA2(first_name || '||' || last_name || '||' || email, 256))

• **sat_product**: 
  - attributes: product_name, category, retail_price
  - product_hashdiff = HEX_ENCODE(SHA2(product_name || '||' || category || '||' || retail_price, 256))

• All sats include load_dts + record_source

## Build Flow (how models are built)

### Ingest (Python)
• Use GCP ADC to query BigQuery
• Save DataFrames to Snowflake RAW using write_pandas
• Idempotent: overwrite RAW tables for repeatable demos

### Stage (dbt, views)
• stg_customers, stg_products, stg_order_items standardize BKs and add metadata

### Vault (dbt, tables)
• **Hubs** from staging BKs → hashed PKs
• **Link** from joining hub lookups with staged orders → hashed link PK
• **Satellites** join staging to hubs, compute hashdiff, carry descriptive attributes

## Modularity & Best Practices

• **Separation of concerns**: RAW ↔ STAGING ↔ DV
• **Repeatable keys**: SHA2-256 + hex upper for PKs and diff
• **Grain discipline**:
  - Hub = distinct BK
  - Link = distinct hub-pair per load_dts (grouped, not duplicated)
  - Sat = (h_*_pk, load_dts) unique
• **Metadata**: record_source, load_dts everywhere
• **dbt structure**: models/staging, models/dv/{hubs,links,sats}, schema.yml tests, sources.yml for RAW

## Testing (dbt core + dbt_utils)

• **Core tests**: not_null, unique on hub PKs and BKs
• **dbt_utils.unique_combination_of_columns** on satellites (h_*_pk, load_dts)
• **Optional integrity tests** (relationships/fk_ref) can assert link→hub references

## What each "database" (layer) does in DV terms

• **RAW** → "Raw Vault landing" (technically pre-vault, immutable copy)
• **STAGING** → "Source-specific standardization" (no business logic)
• **DV** → "Enterprise vault":
  - Hubs = business keys & persistent identities
  - Links = relationships between hubs
  - Satellites = history of descriptive attributes with hashdiffs

## Outcome

✅ Two hubs (hub_customer, hub_product)
✅ One link (lnk_customer_product)
✅ Two satellites (sat_customer, sat_product)
✅ Built with dbt, modular, tested, and documented; runs end-to-end from BigQuery → Snowflake RAW → DV