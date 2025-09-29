# Allianz Data Vault (dbt + Snowflake, source: BigQuery)

## Goal
Implement a simple **Data Vault** using **dbt** on **Snowflake**, with data ingested from **BigQuery public datasets**.

## Scope (assignment)
- **Hubs:** `hub_customer`, `hub_product`
- **Link:** `link_customer_product`
- **Satellites:** `sat_customer`, `sat_product`
- **Transforms:** dbt models from RAW → STAGING → DV
- **Quality:** dbt tests (built-in + custom)
- **Docs:** dbt docs + this folder
- **Logs:** captured under `dbt/logs/` and `logs/build_*.log`

## Layers
- **RAW:** `ALLIANZ.RAW.*` (loaded by Python from BQ)
- **STAGING:** `ALLIANZ.STAGING.*` (dbt views; clean BKs)
- **DV:** `ALLIANZ.DV.*` (dbt tables; hubs/links/sats)

## Quickstart
```bash
# one-time
bash scripts/01_python.sh
bash scripts/02_gcp_adc.sh          # GCP Application Default Credentials
# create .env at repo root (no password needed with SSO)
bash scripts/04_ingest.sh           # load RAW
bash scripts/05_dbt.sh              # build DV + tests + logs
