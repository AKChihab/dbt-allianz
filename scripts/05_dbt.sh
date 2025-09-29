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
mkdir -p logs
dbt debug
dbt build --debug 2>&1 | tee "logs/build_$(date +%Y%m%d_%H%M%S).log"
