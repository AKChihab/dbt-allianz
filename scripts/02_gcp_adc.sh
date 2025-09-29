#!/usr/bin/env bash
set -euo pipefail
echo "Launching browser for GCP ADC..."
gcloud auth application-default login
echo "ADC configured."
