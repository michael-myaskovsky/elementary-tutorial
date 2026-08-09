-- depends_on: USAGE_DB.PUBLIC.payments_validation

-- Materialize: Consider materializing this model as a table if it's frequently used
-- and the source data doesn't change often. This can speed up downstream queries.
-- Example: {{ config(materialized='table') }}

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

select
    payment_id,
    order_id,
    payment_method,
    amount
from renamed