{{ config(materialized='table') }}

with s as (select * from {{ ref('stg_products') }}),
     h as (select h_product_pk, product_bk from {{ ref('hub_product') }})
select
  h.h_product_pk,
  s.load_dts,
  UPPER({{ hashdiff(["s.product_name","s.category","s.retail_price"]) }}) as product_hashdiff,
  s.product_name, s.category, s.retail_price,
  s.record_source
from s
join h on s.product_bk = h.product_bk
qualify row_number() over (partition by h.h_product_pk, s.load_dts order by s.load_dts) = 1
