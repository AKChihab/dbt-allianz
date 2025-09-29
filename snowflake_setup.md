short recap of our Snowflake setup for the assignment:

We created a compute warehouse: COMPUTE_WH.

Size: XSMALL.

AUTO_RESUME = TRUE and AUTO_SUSPEND = 60s (saves credits).

We created a database: ALLIANZ.

We created schemas inside ALLIANZ:

RAW (landing data)

STAGING (cleaned BKs)

DV (Data Vault: hubs, links, satellites)

We used ACCOUNTADMIN only for admin tasks.

Created the warehouse and database.

Created a project role: DEV_ROLE.

Granted DEV_ROLE to user DATACHAIN.

We transferred ownership of the warehouse and database to SYSADMIN.

SYSADMIN is the day-to-day owner.

We granted DEV_ROLE the rights it needs:

USAGE on COMPUTE_WH, ALLIANZ, and all three schemas.

CREATE TABLE and CREATE VIEW on RAW, STAGING, DV.

SELECT on current and future tables in DV.

dbt will run with:

role: DEV_ROLE (or SYSADMIN if needed)

warehouse: COMPUTE_WH

database: ALLIANZ

schema: DV

Result: secure, minimal setup. Admin via ACCOUNTADMIN. Daily work via SYSADMIN/DEV_ROLE. Warehouse auto-wakes for dbt runs and sleeps when idle