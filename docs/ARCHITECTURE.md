## Architecture Overview

- RAW: immutable landing area; loaded via dbt seeds here for demo.
- STAGING: cleans data, standardizes BKs, adds `load_dts`, `record_source`.
- DV: hubs (keys), links (relationships), satellites (descriptive attributes + hashdiffs).

### Modeling Rules
- Hubs: one row per distinct business key; columns: `hk_*`, `*_bk`, `load_dts`, `record_source`.
- Links: combine hub hashes; columns: `hk_link`, foreign hub hashes, `load_dts`, `record_source`.
- Satellites: keyed by hub hash; include `hashdiff` for change detection, attributes, `load_dts`, `record_source`.

### Snowflake Settings
- Warehouse `COMPUTE_WH` auto-resume/suspend
- Database `ALLIANZ`; Schemas `RAW`, `STAGING`, `DV`
- Role `DEV_ROLE` has USAGE + CREATE perms as in `setup_allianz.sql`

### Portability
- Keep warehouse-specific functions in staging.
- Use `dbt_utils.generate_surrogate_key` to avoid adapter-specific hashing.

