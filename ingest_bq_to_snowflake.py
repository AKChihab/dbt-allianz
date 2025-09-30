#!/usr/bin/env python3
"""
BigQuery (public) -> Snowflake (RAW) loader
- Source: bigquery-public-data.thelook_ecommerce
- Target: ALLIANZ.RAW.{USERS, PRODUCTS, ORDER_ITEMS}
Prereqs:
  - GCP ADC: `gcloud auth application-default login`
  - Snowflake env vars: SF_ACCOUNT, SF_USER
  - Optional env vars: SF_ROLE (DEV_ROLE), SF_WAREHOUSE (COMPUTE_WH),
                       SF_DATABASE (ALLIANZ), SF_SCHEMA_RAW (RAW), BQ_BILLING_PROJECT
"""

import os
from pathlib import Path
import argparse
import pandas as pd
from google.cloud import bigquery
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas

# ---------- Config helpers ----------
def env(name: str, default: str | None = None, required: bool = False) -> str:
    val = os.getenv(name, default)
    if required and not val:
        raise RuntimeError(f"Missing required env var: {name}")
    return val

#PROJECT_ROOT = Path(__file__).resolve().parent

def read_sql(p: Path) -> str:
    with p.open(encoding="utf-8") as f: return f.read()

def run_sql_file(conn, path: Path):
    cur = conn.cursor()
    for stmt in [s.strip() for s in read_sql(path).split(";") if s.strip()]:
        cur.execute(stmt)
    cur.close()

def get_snowflake_connection():
    # Prefer password auth for local dev if provided
    if os.getenv("SF_PASSWORD"):
        return snowflake.connector.connect(
            user=os.environ["SF_USER"],
            account=os.environ["SF_ACCOUNT"],      # frfstss-rc57380 (named account)
            authenticator="snowflake",             # <— password auth
            password=os.environ["SF_PASSWORD"],
            role=os.getenv("SF_ROLE","DEV_ROLE"),
            warehouse=os.getenv("SF_WAREHOUSE","COMPUTE_WH"),
            database=os.getenv("SF_DATABASE","ALLIANZ"),
            schema=os.getenv("SF_SCHEMA_RAW","RAW"),
        )
    # fallback (only if your account truly has SSO configured)
    return snowflake.connector.connect(
        user=os.environ["SF_USER"],
        account=os.environ["SF_ACCOUNT"],
        authenticator="externalbrowser",
        role=os.getenv("SF_ROLE","DEV_ROLE"),
        warehouse=os.getenv("SF_WAREHOUSE","COMPUTE_WH"),
        database=os.getenv("SF_DATABASE","ALLIANZ"),
        schema=os.getenv("SF_SCHEMA_RAW","RAW"),
    )


def load_df(conn, df: pd.DataFrame, table_name: str):
    if df.empty:
        print(f"[WARN] Skipping {table_name}: DataFrame is empty.")
        return 0
    success, nchunks, nrows, _ = write_pandas(
        conn,
        df,
        table_name=table_name,
        database=os.getenv("SF_DATABASE", "ALLIANZ"),
        schema=os.getenv("SF_SCHEMA_RAW", "RAW"),
        quote_identifiers=False,
        overwrite=True,
    )
    if not success:
        raise RuntimeError(f"write_pandas failed for {table_name}")
    print(f"[OK] Loaded {nrows} rows to RAW.{table_name} in {nchunks} chunk(s).")
    return nrows

def show_preview(name, df, n, show_dtypes=False):
    if n > 0:
        print(f"\n[BQ] Preview {name} (n={min(n,len(df))}) — columns: {list(df.columns)}")
        print(df.head(n).to_string(index=False))
    if show_dtypes:
        print(f"[BQ] Dtypes {name}:\n{df.dtypes.to_string()}")

def main():
    ap = argparse.ArgumentParser(description="Ingest BigQuery public data into Snowflake RAW schema")
    ap.add_argument("--users-limit", type=int, default=10_000)
    ap.add_argument("--products-limit", type=int, default=10_000)
    ap.add_argument("--items-limit", type=int, default=20_000)
    ap.add_argument("--sql-dir", default="sql")
    ap.add_argument("--dry-run", action="store_true", help="Only query BigQuery and print counts")
    #ap.add_argument("--preview-rows", type=int, default=5, help="Rows to print from each dataset (0=off)")
    #ap.add_argument("--show-dtypes", action="store_true", help="Print pandas dtypes per dataset")
    args = ap.parse_args()

    sql_dir = Path(args.sql_dir)
    bq_project = os.getenv("BQ_BILLING_PROJECT")  # optional
    print(f"[BQ] Project: {bq_project or '(ADC default)'}")
    bq = bigquery.Client(project=bq_project)

    print(f"[BQ] Querying users (limit={args.users_limit}) ...")
    users = bq.query(read_sql(sql_dir/"bq/users.sql").format(limit=args.users_limit)).to_dataframe()
    print(f"[BQ] Users rows: {len(users)}")
    #show_preview("USERS", users, args.preview_rows, args.show_dtypes)

    print(f"[BQ] Querying products (limit={args.products_limit}) ...")
    prods = bq.query(read_sql(sql_dir/"bq/products.sql").format(limit=args.products_limit)).to_dataframe()
    print(f"[BQ] Products rows: {len(prods)}")
    #show_preview("PRODUCTS", prods, args.preview_rows, args.show_dtypes)

    print(f"[BQ] Querying order_items (limit={args.items_limit}) ...")
    items = bq.query(read_sql(sql_dir/"bq/order_items.sql").format(limit=args.items_limit)).to_dataframe()
    print(f"[BQ] Order items rows: {len(items)}")
    #show_preview("ORDER_ITEMS", items, args.preview_rows, args.show_dtypes)

    if args.dry_run:
        print("[DRY RUN] Skipping Snowflake load.")
        return

    print("[SF] Connecting to Snowflake …")
    conn = get_snowflake_connection()

    print("[SF] Ensuring RAW tables exist …")
    run_sql_file(conn, sql_dir / "sf" / "create_raw_tables.sql")

    # Ensure column order matches DDL
    print("[SF] Ensuring column order matches DDL")
    users = users[["user_id","first_name","last_name","email","created_at"]]
    prods = prods[["product_id","product_name","category","retail_price"]]
    items = items[["order_item_id","order_id","customer_id","product_id","order_ts","sale_price"]]


    print("[SF] Loading dataframes into RAW …")
    total = 0
    total += load_df(conn, users, "USERS")
    total += load_df(conn, prods, "PRODUCTS")
    total += load_df(conn, items, "ORDER_ITEMS")

    #cur.close()
    conn.close()
    print(f"[DONE] Loaded total rows: {total}")


if __name__ == "__main__":
    main()
    