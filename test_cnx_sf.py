import os, snowflake.connector

print("SF_ACCOUNT=", os.getenv("SF_ACCOUNT"))
print("SF_USER   =", os.getenv("SF_USER"))
print("SF_ROLE   =", os.getenv("SF_ROLE"))
print("SF_WAREHOUSE   =", os.getenv("SF_WAREHOUSE"))
print("SF_DATABASE   =", os.getenv("SF_DATABASE"))
print("SF_SCHEMA_RAW   =", os.getenv("SF_SCHEMA_RAW"))

c = snowflake.connector.connect(
  user=os.environ["SF_USER"],
  account=os.environ["SF_ACCOUNT"],
  authenticator="snowflake",
  password=os.environ["SF_PASSWORD"],
  role=os.getenv("SF_ROLE","DEV_ROLE"),
  warehouse=os.getenv("SF_WAREHOUSE","COMPUTE_WH"),
  database=os.getenv("SF_DATABASE","ALLIANZ"),
  schema=os.getenv("SF_SCHEMA_RAW","RAW"),
)

cur = c.cursor()
print(cur.execute("select current_account(), current_account_name(), current_region()").fetchall())
cur.close()
c.close()
