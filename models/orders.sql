-- Consider adding an index on order_id and partitioning by order_date for better performance
{{ config(materialized='table') }}

select
    o.order_id,
    o.order_date,
    o.customer_id,
    o.status,
    c.first_name,
    c.last_name,
    c.email
from {{ ref('stg_orders') }} o
left join {{ ref('stg_customers') }} c on o.customer_id = c.customer_id