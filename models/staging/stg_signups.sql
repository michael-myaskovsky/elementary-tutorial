-- depends_on: USAGE_DB.PUBLIC.signups_validation

with source as (
    select
        id,
        user_id,
        user_email,
        hashed_password,
        signup_date
    from USAGE_DB.PUBLIC.signups_training
),

renamed as (
    select
        id as signup_id,
        user_id as customer_id,
        user_email as customer_email,
        hashed_password,
        signup_date
    from source
)

select
    signup_id,
    customer_id,
    customer_email,
    hashed_password,
    signup_date
from renamed