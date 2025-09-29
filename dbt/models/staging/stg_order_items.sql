with s as (select * from {{ source('raw','order_items') }})
select
  upper(trim(cast(customer_id as string))) as customer_bk,
  upper(trim(cast(product_id as string)))  as product_bk,
  order_id, order_ts, sale_price, quantity,
  'BQ_ORDERS' as record_source,
  current_timestamp() as load_dts
from s
