{{ config(materialized='table') }}

with source as (
    select * from {{ source('elementary_tutorial', var('signups_table', 'signups_validation')) }}
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