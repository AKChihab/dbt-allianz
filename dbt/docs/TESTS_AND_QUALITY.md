
---

### dbt/docs/TESTS_AND_QUALITY.md

# Tests & Data Quality

## Goal
- Ensure keys are present and unique, relationships are valid, and satellites enforce one-row-per-key-per-load.

## Where tests live
- Staging tests: `dbt/models/staging/schema.yml`
- DV tests (hubs/links/sats): `dbt/models/dv/schema.yml`
- Custom generic test: `dbt/tests/generic/fk_ref.sql`

## Built-in tests we use
- Staging
  - stg_customers: `not_null(customer_bk)`, `not_null(load_dts)`
  - stg_products: `not_null(product_bk)`, `not_null(load_dts)`
  - stg_order_items: `not_null(customer_bk)`, `not_null(product_bk)`, `not_null(load_dts)`
  - Purpose: conformed BKs and metadata cannot be null before vaulting.

- Hubs
  - hub_customer: `unique(h_customer_pk)`, `not_null(h_customer_pk)`, `not_null(customer_bk)`
  - hub_product: `unique(h_product_pk)`, `not_null(h_product_pk)`, `not_null(product_bk)`
  - Purpose: DV keys are stable and unique; BK columns are recorded.

- Link
  - link_customer_product: `unique(l_customer_product_pk)`, `not_null(l_customer_product_pk)`
  - Purpose: relationship rows are deduplicated and present.

- Satellites
  - sat_customer: `dbt_utils.unique_combination_of_columns(arguments: [h_customer_pk, load_dts])`, `not_null(h_customer_pk)`, `not_null(load_dts)`, `not_null(customer_hashdiff)`
  - sat_product: `dbt_utils.unique_combination_of_columns(arguments: [h_product_pk, load_dts])`, `not_null(h_product_pk)`, `not_null(load_dts)`, `not_null(product_hashdiff)`
  - Purpose: one satellite row per (hub_pk, load_dts); hashdiff and keys must exist.

## Custom generic test: fk_ref.sql
- File: `dbt/tests/generic/fk_ref.sql`
- What it checks: referential integrity for FKs in the link
  - Child → Parent: `h_customer_pk` → `hub_customer.h_customer_pk`
  - Child → Parent: `h_product_pk` → `hub_product.h_product_pk`
- Logic: left join child to parent; if any parent is missing, the query returns rows and the test fails.

## Running tests and reading results
```bash
cd dbt
dbt test --profiles-dir ../profiles         # run tests only
dbt build --profiles-dir ../profiles        # run + test (what scripts/05_dbt.sh does)

# Inspect artifacts
cat target/run_results.json | jq '.'
```

## Results (latest run)
- Summary: PASS=29, WARN=0, ERROR=0 (see `logs/build_YYYYMMDD_HHMMSS.log`).
- Engine log: `dbt/logs/dbt.log` (append-only, detailed adapter messages).

## Notes / fixes informed by tests and logs
- Replaced `TO_HEX` with `HEX_ENCODE(SHA2(...,256))` to satisfy Snowflake.
- Nested generic test inputs under `arguments:` to silence deprecations.
- Ensured link FKs point to the correct hub PKs and pass `fk_ref`.