with source as (
    select
        id,
        order_id,
        payment_method,
        amount
    from USAGE_DB.PUBLIC.payments_training
),

renamed as (
    select
        id as payment_id,
        order_id,
        payment_method,
        -- `amount` is currently stored in cents, so we convert it to dollars
        amount / 100 as amount
    from source
)

select * from renamed