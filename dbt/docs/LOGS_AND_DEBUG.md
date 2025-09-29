
---

### dbt/docs/LOGS_AND_DEBUG.md
```markdown
# Logs & Debugging

## Logs
- **dbt CLI:** `dbt/logs/dbt.log`
- **Build transcript:** `logs/build_YYYYMMDD_HHMMSS.log` (from `scripts/05_dbt.sh`)
- **Snowflake query history:** filter by `QUERY_TAG = 'allianz_dbt'` (set in profiles.yml)

## Common checks
```bash
dbt debug           # connection, credentials, adapters
dbt ls              # list models selected
dbt run -s staging  # build staging only
dbt test -s dv.*    # tests for vault only
