{{ config(materialized='table') }}

with s as (select * from {{ ref('stg_customers') }}),
     h as (select h_customer_pk, customer_bk from {{ ref('hub_customer') }})
select
  h.h_customer_pk,
  s.load_dts,
  {{ hashdiff(["s.first_name","s.last_name","s.email"]) }} as customer_hashdiff,
  s.first_name, s.last_name, s.email, s.created_at,
  s.record_source
from s join h on s.customer_bk = h.customer_bk
group by 1,2,3,4,5,6,7,8