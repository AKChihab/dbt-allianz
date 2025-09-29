# Runbook

## Prereqs
- Snowflake trial ready; run `setup_allianz.sql` once in Snowsight.
- `COMPUTE_WH` (XSMALL, auto-resume), DB `ALLIANZ`, schemas `RAW/STAGING/DV`.
- Role for dbt: `DEV_ROLE` with USAGE/CREATE grants on schemas and warehouse.
- GCP: `gcloud auth application-default login` (ADC).

## Environment
Create `.env` at repo root (no secrets echoed):

## First-time setup
```bash
bash scripts/01_python.sh     # venv + pip install
bash scripts/02_gcp_adc.sh    # GCP ADC browser login
bash scripts/04_ingest.sh
## optional limits:
bash scripts/04_ingest.sh -- --users-limit 2000 --products-limit 2000 --items-limit 4000
bash scripts/05_dbt.sh