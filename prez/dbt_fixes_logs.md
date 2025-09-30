# Presentation notes: key adjustments and fixes we made (with impact)

## Profile mismatch (dbt couldn't find project)
- **Change:** set profile: allianz_dv_snowflake in dbt/dbt_project.yml.
- **Impact:** dbt debug succeeded using profiles/profiles.yml.

## Staging and DV schemas created with wrong names (privilege errors)
- **Symptom (log):** "Creating schema DV_STAGING / DV_DV … 003001 (42501) Insufficient privileges".
- **Change:** added dbt/macros/generate_schema_name.sql to use STAGING and DV exactly.
- **Impact:** models now materialize to ALLIANZ.STAGING and ALLIANZ.DV.

## Snowflake hash function error
- **Symptom (log):** "Unknown function TO_HEX".
- **Change:** replaced TO_HEX(SHA2(...)) with HEX_ENCODE(SHA2(...,256)) in dbt/macros/hash.sql; hubs updated.
- **Impact:** hubs built successfully on next run.

## Source table naming inconsistency
- **Symptom:** staging failed on missing RAW table customers.
- **Change:** dbt/models/sources.yml → users; stg_customers.sql now reads source('raw','users').
- **Impact:** stg_customers created; tests passed.

## Custom FK test macro compilation error
- **Symptom (log):** "non-default argument follows default argument".
- **Change:** reordered signature in dbt/tests/generic/fk_ref.sql (required params first); updated test usage in dv/schema.yml.
- **Impact:** FK tests compiled and ran.

## Deprecation warnings for generic tests
- **Symptom (log):** "MissingArgumentsPropertyInGenericTestDeprecation".
- **Change:** nested generic test inputs under arguments: in dbt/models/dv/schema.yml.
- **Impact:** warning silenced in later runs.

## Scripted logs and reliable transcripts
- **Change:** scripts/05_dbt.sh runs from dbt/, sets --profiles-dir, and tee's to ../logs/build_YYYYMMDD_HHMMSS.log.
- **Note:** external transcripts are outside dbt/ so they persist even after dbt clean.
- **Impact:** we preserved run history; easy diff between failing and passing runs.

## Incrementalization of link (performance)
- **Change:** lnk_customer_product materialized as incremental (unique key). Optional filter by o.load_dts for newer loads.
- **Operation:** one-time --full-refresh for a clean incremental baseline.
- **Impact:** faster subsequent runs while maintaining correctness.

## Telemetry noise in logs
- **Symptom (log):** "An error was encountered while trying to flush usage events".
- **Change:** export DBT_SEND_ANONYMOUS_USAGE_STATS=false in scripts/05_dbt.sh.
- **Impact:** cleaner console and transcripts.

## Final confirmation (success)
- **Proof:** logs/build_20250930_195233.log ends with "Completed successfully … PASS=29 WARN=0 ERROR=0".
- **Artifacts:** dbt/target/run_results.json and manifest.json captured for audit.