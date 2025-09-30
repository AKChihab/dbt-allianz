{{ config(materialized='incremental', unique_key=['l_customer_product_pk']) }}

with c as (
select h_customer_pk, customer_bk from {{ ref('hub_customer') }}
),
     p as (
select h_product_pk,  product_bk  from {{ ref('hub_product') }}
),
     o as (
select customer_bk, product_bk, record_source, load_dts from {{ ref('stg_order_items') }}
)

select
  {{ hashkey(['c.h_customer_pk','p.h_product_pk']) }} as l_customer_product_pk,
  c.h_customer_pk,
  p.h_product_pk,
  o.record_source,
  o.load_dts
from o
join c using (customer_bk)
join p using (product_bk)
group by 1,2,3,4,5