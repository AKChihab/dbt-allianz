{{ config(materialized='table') }}

select
  {{ hashkey(['customer_bk']) }} as h_customer_pk,
  customer_bk, record_source, load_dts
from {{ ref('stg_customers') }}
group by 1,2,3,4
