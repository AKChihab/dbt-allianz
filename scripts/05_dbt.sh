#!/usr/bin/env bash
set -euo pipefail

# Load .env just for this script run (export all vars)
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

source .venv/bin/activate
export DBT_PROFILES_DIR="${DBT_PROFILES_DIR:-$(pwd)/profiles}"
export DBT_SEND_ANONYMOUS_USAGE_STATS=false

cd dbt
dbt deps | cat
mkdir -p ../logs
dbt debug --profiles-dir "${DBT_PROFILES_DIR}" | cat
dbt build --debug --profiles-dir "${DBT_PROFILES_DIR}" 2>&1 | tee "../logs/build_$(date +%Y%m%d_%H%M%S).log"
