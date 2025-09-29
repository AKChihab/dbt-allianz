#!/usr/bin/env bash
set -euo pipefail
# load .env if present
[[ -f .env ]] && { set -a; source .env; set +a; }
source .venv/bin/activate
python ingest_bq_to_snowflake.py "$@"