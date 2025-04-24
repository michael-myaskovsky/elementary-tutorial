-- Consider adding indexes on order_id in both stg_orders and stg_payments tables
-- Also, consider partitioning the stg_orders table by order_date if it spans a wide range of dates

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_payments as (
    select
        order_id,
        sum(amount) as amount
    from {{ ref('stg_payments') }}
    group by 1
)

select
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.status,
    coalesce(order_payments.amount, 0) as amount

from orders
left join order_payments using (order_id)