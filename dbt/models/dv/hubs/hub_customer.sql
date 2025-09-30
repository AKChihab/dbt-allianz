{{ config(materialized='table') }}

select
  UPPER(HEX_ENCODE(SHA2(COALESCE(CAST(customer_bk AS VARCHAR), ''), 256))) as h_customer_pk,
  customer_bk, record_source, load_dts
from {{ ref('stg_customers') }}
group by 1,2,3,4
