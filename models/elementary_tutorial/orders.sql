{{ config(materialized='table') }}

with orders as (
    select order_id, customer_id, order_date, status 
    from {{ ref('stg_orders') }}
),
payments as (
    select order_id, payment_method, amount 
    from {{ ref('stg_payments') }}
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
),
final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        order_payments.credit_card_amount,
        order_payments.coupon_amount,
        order_payments.bank_transfer_amount,
        order_payments.gift_card_amount,
        order_payments.total_amount as amount
    from orders
    left join order_payments
        on orders.order_id = order_payments.order_id
)
select * from final

-- If this model is materialized as a table, consider adding an index on order_id
-- CREATE INDEX idx_orders_order_id ON {{ this }}(order_id);