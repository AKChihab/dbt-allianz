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
