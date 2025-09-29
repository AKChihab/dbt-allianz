## YAML Setup Guide

### schema.yml placement
- Put one `schema.yml` per folder (e.g., `models/staging/schema.yml`, `models/dv/schema.yml`).

### Common tests
- `not_null`, `unique` for hub/link keys.
- `relationships` for link/satellite FK to hubs.
- `dbt_utils.unique_combination_of_columns` for satellite uniqueness.

### Descriptions
- Add `description` to each model and important columns.

### Sources (optional extension)
- Define `sources:` to map RAW tables when not using seeds.

