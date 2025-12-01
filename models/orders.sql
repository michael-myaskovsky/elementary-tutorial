{{ config(materialized='table') }}

with orders as (

    select * from {{ ref('stg_orders') }}

),

order_payments as (

    select
        order_id,
        sum(case when status = 'success' then amount end) as amount

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