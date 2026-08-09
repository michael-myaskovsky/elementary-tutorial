-- depends_on: USAGE_DB.PUBLIC.customers_validation

select
    id as customer_id,
    first_name,
    last_name
from {{ source('usage_db', 'customers_training') }}