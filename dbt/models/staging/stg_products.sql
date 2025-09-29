with s as (select * from {{ source('raw','products') }})
select
  upper(trim(cast(product_id as string))) as product_bk,
  product_name, category, retail_price,
  'BQ_PRODUCTS' as record_source,
  current_timestamp() as load_dts
from s
