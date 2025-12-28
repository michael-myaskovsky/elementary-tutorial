
-- Optimize orders model

-- Consider materializing these CTEs if used multiple times
with orders as (
    select * from {{ source('jaffle_shop', 'orders') }}
),

payments as (
    select * from {{ source('stripe', 'payments') }}
),

order_payments as (
    select
        order_id,
        sum(case when payment_method = 'credit_card' then amount else 0 end) as credit_card_amount,
        sum(case when payment_method = 'coupon' then amount else 0 end) as coupon_amount,
        sum(case when payment_method = 'bank_transfer' then amount else 0 end) as bank_transfer_amount,
        sum(case when payment_method = 'gift_card' then amount else 0 end) as gift_card_amount,
        sum(amount) as total_amount
    from payments
    group by order_id
)

-- Ensure that both 'orders' and 'order_payments' tables have appropriate indexes on order_id
select
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.status,
    order_payments.total_amount as amount,
    order_payments.credit_card_amount,
    order_payments.coupon_amount,
    order_payments.bank_transfer_amount,
    order_payments.gift_card_amount

from orders
left join order_payments on orders.order_id = order_payments.order_id

-- TODO: Review if all payment method columns are necessary. Remove unused columns to simplify the query and potentially improve performance.
