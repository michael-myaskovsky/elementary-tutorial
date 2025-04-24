-- depends_on: USAGE_DB.PUBLIC.orders_validation

-- This staging model prepares order data for downstream models
-- by selecting relevant columns and renaming them for consistency.

with source as (
    select * from USAGE_DB.PUBLIC.orders_training
    -- Uncomment the following line if you only need recent data
    -- where order_date >= dateadd(day, -90, current_date)
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