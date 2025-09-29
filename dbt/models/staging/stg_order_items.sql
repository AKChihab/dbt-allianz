with source as (
    select
        customer_id,
        product_id,
        interaction_type,
        cast(interaction_ts as timestamp) as interaction_ts,
        coalesce(record_source, 'seed')    as record_source,
        cast(load_dts as timestamp)        as load_dts
    from {{ ref('raw_customer_product') }}
),
conformed as (
    select
        trim(upper(customer_id)) as customer_bk,
        trim(upper(product_id))  as product_bk,
        interaction_type,
        interaction_ts,
        record_source,
        load_dts
    from source
)
select * from conformed

