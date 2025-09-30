
---

### dbt/docs/LOGS_AND_DEBUG.md
```markdown
# Logs & Debugging

## Where logs are captured
- **dbt engine log (inside project):** `dbt/logs/dbt.log`
  - Append-only. Detailed adapter/engine messages. Survives multiple runs.
- **Run transcripts (outside project):** `logs/build_YYYYMMDD_HHMMSS.log`
  - Created by `scripts/05_dbt.sh` using `tee`. Each run gets a timestamped file.
  - Safe from `dbt clean` because it lives one level above `dbt/`.
- **Query history in Snowflake:** filter by `QUERY_TAG = 'allianz_dbt'`.

## How we capture logs (scripted)
- `scripts/05_dbt.sh` does:
  - `export DBT_SEND_ANONYMOUS_USAGE_STATS=false` (less noise)
  - `cd dbt && dbt deps && dbt debug` (pre-flight checks)
  - `dbt build --debug --profiles-dir ../profiles 2>&1 | tee ../logs/build_$(date +%Y%m%d_%H%M%S).log`
  - This keeps dbt’s own log in `dbt/logs/dbt.log` and the full console in `logs/`.

## Clean runs vs persisted logs
- We used `dbt clean` during development. It removes `target/`, `dbt_packages/`, and can remove `dbt/logs`.
- External transcripts under `logs/` remain intact, so we can compare runs over time.

## Examples: successful execution
- Example success file: `logs/build_20250930_195233.log` shows `PASS=29 WARN=0 ERROR=0`.
- Artifacts for the same run: `dbt/target/run_results.json`, `manifest.json`.

## Issues found and resolved using logs
- BigQuery access/location:
  - Symptom: 403 Access Denied or location mismatch in `dbt/logs/dbt.log` or ingest script output.
  - Fix: set billing project and `--bq-project`; use US location for `thelook_ecommerce`.
  - Logs: failure `logs/build_20250930_194418.log`, success `logs/build_20250930_195233.log`.
- Snowflake account host / SSO:
  - Symptom: 404 or SAML IdP errors in engine logs.
  - Fix: set `SF_ACCOUNT` to the exact identifier (e.g., `dv76312.europe-west3.gcp`); switch to `password` auth when needed.
  - Logs: failure `logs/build_20250930_194418.log`, success `logs/build_20250930_195233.log`.
- Hash function compatibility:
  - Symptom: `Unknown function TO_HEX` errors in build transcripts.
  - Fix: replaced `TO_HEX(...)` with `HEX_ENCODE(SHA2(...,256))` in `dbt/macros/hash.sql`.
  - Logs: failure `logs/build_20250930_194418.log`, success `logs/build_20250930_195233.log`.
- Schema naming / permissions:
  - Symptom: attempts to create `DV_STAGING` / `DV_DV` and `003001 (42501)` privilege errors.
  - Fix: added `macros/generate_schema_name.sql` to honor `STAGING` and `DV` exactly; ensured role grants.
  - Logs: failure `logs/build_20250930_201823.log`, success `logs/build_20250930_195233.log`.
- Generic test args deprecation:
  - Symptom: deprecation warnings about test arguments placement.
  - Fix: nested `arguments:` under generic tests in `models/dv/schema.yml`.
  - Logs: failure `logs/build_20250930_194418.log`, success `logs/build_20250930_195233.log`.

## Useful commands (quick reference)
```bash
# Tail dbt engine logs
tail -f dbt/logs/dbt.log

# Run and capture transcript (already done by 05_dbt.sh)
dbt build --debug --profiles-dir ../profiles 2>&1 | tee ../logs/build_$(date +%Y%m%d_%H%M%S).log

# One-off full refresh of link with its own transcript
dbt run --profiles-dir ../profiles -s lnk_customer_product --full-refresh \
  2>&1 | tee ../logs/run_lnk_fullrefresh_$(date +%Y%m%d_%H%M%S).log

# Inspect artifacts
cat dbt/target/run_results.json | jq '.'
