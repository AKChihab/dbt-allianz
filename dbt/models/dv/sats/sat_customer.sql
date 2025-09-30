{{ config(materialized='table') }}

with s as (select * from {{ ref('stg_customers') }}),
     h as (select h_customer_pk, customer_bk from {{ ref('hub_customer') }})
select
  h.h_customer_pk,
  s.load_dts,
  UPPER(HEX_ENCODE(SHA2(
      COALESCE(CAST(s.first_name AS VARCHAR), '') || '||' ||
      COALESCE(CAST(s.last_name  AS VARCHAR), '') || '||' ||
      COALESCE(CAST(s.email      AS VARCHAR), '')
  , 256))) as customer_hashdiff,
  s.first_name, s.last_name, s.email, s.created_at,
  s.record_source
from s
join h on s.customer_bk = h.customer_bk
qualify row_number() over (partition by h.h_customer_pk, s.load_dts order by s.load_dts) = 1
