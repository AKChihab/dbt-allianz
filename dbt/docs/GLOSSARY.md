
---
### dbt/docs/GLOSSARY.md
```markdown
# Glossary (DV)

- **Business Key (BK)**: Natural identifier from the source (e.g., `user_id` → `customer_bk`).
- **Hub**: One row per unique BK; PK is the vault key (`h_*_pk`).
- **Link**: Relationship between hubs; PK is a hash of parent hub PKs (`l_*_pk`).
- **Satellite**: Descriptive attributes for a hub (or link); carries `hashdiff` and `load_dts`.
- **Hashkey**: Deterministic PK computed from BK (or PKs); used for joins and dedupe.
- **Hashdiff**: Deterministic hash of descriptive attributes; detects changes quickly.
- **Record Source**: Provenance label (e.g., `BQ_USERS`, `BQ_PRODUCTS`).
- **Load DTS**: Load timestamp for auditability and SCD behavior.
