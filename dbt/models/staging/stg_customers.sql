with s as (select * from {{ source('raw','users') }})
select
  upper(trim(cast(user_id as string))) as customer_bk,
  first_name, last_name, email, created_at,
  'BQ_USERS' as record_source,
  current_timestamp() as load_dts
from s