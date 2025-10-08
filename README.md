# Allianz DV (BigQuery -> Snowflake -> dbt)

## Steps
1) **Snowflake bootstrap**: run `setup_allianz.sql` in Snowsight (ACCOUNTADMIN).  
2) **Python & deps**: `bash scripts/01_python.sh`  
3) **GCP ADC**: `bash scripts/02_gcp_adc.sh`  
4) **.env**: create at repo root with:
5) **Ingest RAW**: `bash scripts/04_ingest.sh`  
6) **dbt build & tests**: `bash scripts/05_dbt.sh`  
7) **Docs**: `dbt docs generate` (optional `dbt docs serve`)

## Deliverables
- **Models**: hubs, link, satellites (SQL above)  
- **Tests**: built-in + custom `fk_ref`  
- **Docs**: descriptions + lineage  
- **Logs**: `logs/build_*.log` and `target/logs/dbt.log`

## Setup & Run

### Prerequisites
- Python 3.11+, bash, git
- Snowflake account (role with USAGE on `COMPUTE_WH` and CREATE in `ALLIANZ`)
- gcloud CLI (for BigQuery Application Default Credentials)

### One-time Snowflake bootstrap
Run in Snowsight as ACCOUNTADMIN:
```
setup_allianz.sql
```

### Environment (shell or .env)
```bash
# Snowflake
export SF_ACCOUNT="<SF_ACCOUNT>"   # use your exact identifier
export SF_USER="<SF_USER>"
export SF_ROLE="DEV_ROLE"
export SF_WAREHOUSE="<SF_WAREHOUSE>" 
export SF_DATABASE="ALLIANZ"
export SF_SCHEMA="DV"
# optional if using password auth
# export SF_PASSWORD="<password>"

# dbt profiles
export DBT_PROFILES_DIR="$(pwd)/profiles"

# BigQuery (US for thelook_ecommerce)
export BQ_BILLING_PROJECT="<your-gcp-project-id>"
gcloud auth application-default login
gcloud auth application-default set-quota-project "$BQ_BILLING_PROJECT"
```

### Quickstart
```bash
bash scripts/01_python.sh           # venv + deps
bash scripts/02_gcp_adc.sh          # GCP ADC login
bash scripts/04_ingest.sh           # load RAW from BigQuery to Snowflake
bash scripts/05_dbt.sh              # build DV + tests + logs
```

### Manual dbt (optional)
```bash
cd dbt
dbt deps
dbt debug --profiles-dir ../profiles
dbt build --profiles-dir ../profiles
```

### Logs & artifacts
- Engine: `dbt/logs/dbt.log` (append-only)
- Transcripts: `logs/build_YYYYMMDD_HHMMSS.log` (outside `dbt/`, persists across `dbt clean`)
- Artifacts: `dbt/target/run_results.json`, `dbt/target/manifest.json`

### Docs
```bash
cd dbt
dbt docs generate --profiles-dir ../profiles
# optional: dbt docs serve
```

### Troubleshooting
- BigQuery access/location: set `BQ_BILLING_PROJECT`, use US location for `thelook_ecommerce`.
- Snowflake host/SSO: set `SF_ACCOUNT` exactly; use password auth if needed.
- Hash function error: use `HEX_ENCODE(SHA2(...,256))` (already in macros).
- Schema naming: macro `generate_schema_name` pins `STAGING` and `DV`.

### Incremental link (optional)
```bash
cd dbt
dbt run --profiles-dir ../profiles -s lnk_customer_product --full-refresh
```
