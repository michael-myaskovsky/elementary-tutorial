-- models/elementary_tutorial/orders.sql

-- Suggestion: Ensure 'order_id' is indexed in both stg_orders and stg_payments tables

-- Suggestion: Consider partitioning the final table by order_date if the date range is wide

with order_payments as (
    select
        order_id,
        sum(amount) as amount
    from {{ ref('stg_payments') }}
    group by 1
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    coalesce(op.amount, 0) as amount
from {{ ref('stg_orders') }} o
left join order_payments op using (order_id)

-- Suggestion: If there are common filters applied to this data in downstream models,
-- consider adding them here for predicate pushdown, e.g.:
-- where o.order_date >= date_trunc('month', current_date) - interval '3 months'