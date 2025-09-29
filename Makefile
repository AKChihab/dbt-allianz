SHELL := bash
.ONESHELL:

setup: py adc # env          
py:    ; bash scripts/01_python.sh
adc:   ; bash scripts/02_gcp_adc.sh
#env:   ; bash scripts/03_env.sh
ingest:; bash scripts/04_ingest.sh
build: ; bash scripts/05_dbt.sh
all: setup ingest build