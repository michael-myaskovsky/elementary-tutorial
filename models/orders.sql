{{ config(materialized='table') }}

{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with orders as (
    select * from {{ ref('stg_orders') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

payment_methods as (
    select unnest(array['credit_card', 'coupon', 'bank_transfer', 'gift_card']) as payment_method
),

order_payments as (
    select
        order_id,
        payment_method,
        sum(amount) as amount
    from payments
    group by order_id, payment_method
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        coalesce(op.amount, 0) as amount,
        pm.payment_method
    from orders
    cross join payment_methods pm
    left join order_payments op
        on orders.order_id = op.order_id
        and pm.payment_method = op.payment_method
)

select
    order_id,
    customer_id,
    order_date,
    status,
    sum(case when payment_method = 'credit_card' then amount else 0 end) as credit_card_amount,
    sum(case when payment_method = 'coupon' then amount else 0 end) as coupon_amount,
    sum(case when payment_method = 'bank_transfer' then amount else 0 end) as bank_transfer_amount,
    sum(case when payment_method = 'gift_card' then amount else 0 end) as gift_card_amount,
    sum(amount) as total_amount
from final
group by order_id, customer_id, order_date, status