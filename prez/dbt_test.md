# Testing Documentation (Presentation-Ready)

## Goal
• Validate keys, relationships, and vault change-capture logic
• Fail fast on nulls, duplicates, and broken FKs

## Staging Tests
• **stg_customers:** `not_null(customer_bk)`, `not_null(load_dts)`
• **stg_products:** `not_null(product_bk)`, `not_null(load_dts)`
• **stg_order_items:** `not_null(customer_bk)`, `not_null(product_bk)`, `not_null(load_dts)`
• **Purpose:** Conformed business keys and metadata must always be populated before DV
• **Result:** All passed in latest run

## Hub Tests
• **hub_customer:** `unique(h_customer_pk)`, `not_null(h_customer_pk)`, `not_null(customer_bk)`
• **hub_product:** `unique(h_product_pk)`, `not_null(h_product_pk)`, `not_null(product_bk)`
• **Purpose:** DV keys are unique and present; BK recorded for traceability
• **Result:** All passed

## Link Tests
• **link_customer_product:** `unique(l_customer_product_pk)`, `not_null(l_customer_product_pk)`
• **Custom FK to hubs:**
  - `h_customer_pk` → `hub_customer.h_customer_pk`
  - `h_product_pk` → `hub_product.h_product_pk`
• **Purpose:** Every relationship row points to valid hub rows; link PK dedupes the relationship
• **Result:** All passed
• **FK Test Example:**
  - Think of two lists:
    - Parent list: all real customers (each has a unique ID)
    - Child list: all customer-product links (each row points to a customer ID)
  - Rule: every customer ID in the child list must exist in the parent list (Foreign Key rule)
  - **Tiny example:**
    - Parent (customers): [C1, C2]
    - Child (links): [C1→P100], [C2→P200], [C3→P300]
    - Problem: C3 isn't in the parent list, so that child row is "orphan" → FK test fails
  - **What the FK test does (tests/generic/fk_ref.sql):**
    - Matches each child row to the parent row by ID
    - If it can't find a parent, it flags that child row
    - Pass = no orphans; Fail = at least one orphan
  - **In your project:**
    - Child: `link_customer_product.h_customer_pk`
    - Parents: `hub_customer.h_customer_pk` and `hub_product.h_product_pk`
    - The test ensures every link points to real hubs, so diagrams and joins never break


## Satellite Tests
• **sat_customer:**
  - `dbt_utils.unique_combination_of_columns(arguments: [h_customer_pk, load_dts])`
  - `not_null(h_customer_pk)`, `not_null(load_dts)`, `not_null(customer_hashdiff)`
• **sat_product:**
  - `dbt_utils.unique_combination_of_columns(arguments: [h_product_pk, load_dts])`
  - `not_null(h_product_pk)`, `not_null(load_dts)`, `not_null(product_hashdiff)`
• **Purpose:** Vault SCD behavior—no duplicate satellite rows per (hub_pk, load_dts); hashdiff and keys are non-null
• **Result:** All passed

## Custom Generic Test: fk_ref.sql
• **What it checks:** Asserts referential integrity: child FK must exist in parent PK
• **Implementation:** Left join and search for missing parents (fail if any found)
• **Applied to:** link → hub_customer, link → hub_product
• **Result:** Passed; no orphan relationships

## Evidence (Latest Successful Run)
• **Summary:** PASS=29, WARN=0, ERROR=0
• **Artifacts:** 
  - `dbt/target/run_results.json`
  - `dbt/logs/dbt.log`
  - External transcripts in `logs/build_YYYYMMDD_HHMMSS.log`

## Notes
• We resolved early failures seen in logs (hash function, test arg placement) and re-ran until all tests passed
• Test arguments for generic tests are nested under `arguments:` to avoid deprecation warnings