{{ config(materialized='table') }}

select
  {{ hashkey(['product_bk']) }} as h_product_pk,
  product_bk, record_source, load_dts
from {{ ref('stg_products') }}
group by 1,2,3,4
