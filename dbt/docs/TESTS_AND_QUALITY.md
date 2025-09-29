
---

### dbt/docs/TESTS_AND_QUALITY.md
```markdown
# Tests & Data Quality

## Built-in tests
- **Hubs:** `unique` + `not_null` on `h_*_pk`
- **Link:** `unique` + `not_null` on `l_*_pk`, FKs to hub PKs (custom test)
- **Satellites:** `unique_combination_of_columns` on `(h_*_pk, load_dts)` + `not_null` on keys/hashdiff

## Custom generic tests
- `tests/generic/fk_ref.sql`: foreign key integrity
  ```yaml
  - name: link_customer_product
    columns:
      - name: h_customer_pk
        tests:
          - fk_ref:
              parent_model: ref('hub_customer')
              pk_column: h_customer_pk
