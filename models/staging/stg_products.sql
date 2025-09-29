with source as (
    select
        product_id,
        product_name,
        category,
        coalesce(record_source, 'seed') as record_source,
        cast(load_dts as timestamp)      as load_dts
    from {{ ref('raw_products') }}
),
conformed as (
    select
        trim(upper(product_id))   as product_bk,
        product_name,
        category,
        record_source,
        load_dts
    from source
)
select * from conformed

