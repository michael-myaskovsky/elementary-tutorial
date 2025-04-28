with source as (
    select 
        id,
        user_id,
        order_date,
        status
    from {{ source('public', 'orders_training') }}
),

renamed as (
    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status
    from source
)

select * from renamed