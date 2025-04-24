with source as (
    select * from {{ source('elementary_tutorial', 'orders_training') }}
),

renamed as (
    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status,
        amount
    from source
)

select * from renamed