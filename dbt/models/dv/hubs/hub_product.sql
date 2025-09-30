{{ config(materialized='table') }}

select
  UPPER(HEX_ENCODE(SHA2(COALESCE(CAST(product_bk  AS VARCHAR), ''), 256))) as h_product_pk,
  product_bk, record_source, load_dts
from {{ ref('stg_products') }}
group by 1,2,3,4
