
---

### dbt/docs/ARCHITECTURE.md
```markdown
# Architecture

## Source → Target
- **Source (BQ):** `bigquery-public-data.thelook_ecommerce`
  - `users`, `products`, `orders` + `order_items` (join done in extract)
- **Landing (Snowflake RAW):**
  - `ALLIANZ.RAW.USERS`
  - `ALLIANZ.RAW.PRODUCTS`
  - `ALLIANZ.RAW.ORDER_ITEMS`

## Staging (dbt)
- Standardize BKs, add metadata.
- `stg_customer` → `customer_bk`
- `stg_products` → `product_bk`
- `stg_order_items` → `customer_bk`, `product_bk`, `order_ts`, prices, qty
- All staging models add `record_source` and `load_dts`.

## Data Vault (dbt)
- **Hubs**
  - `hub_customer(h_customer_pk, customer_bk, record_source, load_dts)`
  - `hub_product(h_product_pk, product_bk, record_source, load_dts)`
  - PKs are **hashes of BKs** (DV 2.0 style) using macro `hashkey()`.
- **Link**
  - `link_customer_product(l_customer_product_pk, h_customer_pk, h_product_pk, record_source, load_dts)`
  - PK is **hash of parent hub PKs**.
- **Satellites**
  - `sat_customer(h_customer_pk, load_dts, customer_hashdiff, first_name, last_name, email, created_at, record_source)`
  - `sat_product(h_product_pk, load_dts, product_hashdiff, product_name, category, retail_price, record_source)`
  - `hashdiff()` tracks attribute changes.

## Why hashes?
- Deterministic keys across loads/sources, fixed width joins, parallelizable loads.
- Not mandatory, but standard for DV 2.0 and scalable.

## Lineage (dbt)
- RAW → STAGING → DV (hubs/links/sats).  
- Visualize via `dbt docs serve`.
