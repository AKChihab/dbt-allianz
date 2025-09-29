#!/usr/bin/env bash
set -euo pipefail
command -v python3 >/dev/null || { echo "Python3 not found"; exit 1; }
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
if [[ -f requirements.txt ]]; then
  pip install -r requirements.txt
else
  cat > requirements.txt <<'REQ'
google-cloud-bigquery>=3.12,<4
pandas>=2.2,<3
snowflake-connector-python[pandas]>=3.7,<4
dbt-snowflake>=1.8,<1.9
python-dotenv>=1.0,<2
REQ
  pip install -r requirements.txt
fi
echo "venv ready and deps installed."
