#!/usr/bin/env bash
# Usage: source scripts/03_env.sh
set -euo pipefail

if [[ ! -f .env ]]; then
  echo "No .env found. Create it at project root." >&2
  return 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

: "${SF_ACCOUNT:?Missing SF_ACCOUNT}"; : "${SF_USER:?Missing SF_USER}"
: "${SF_ROLE:?Missing SF_ROLE}"; : "${SF_WAREHOUSE:?Missing SF_WAREHOUSE}"
: "${SF_DATABASE:?Missing SF_DATABASE}"
echo ".env loaded and validated."
