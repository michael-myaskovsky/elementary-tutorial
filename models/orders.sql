with orders as (
    select
        order_id,
        customer_id,
        order_date,
        status
    from {{ ref('stg_orders') }}
),

payments as (
    select
        order_id,
        payment_method,
        amount,
        sum(amount) over (partition by order_id) as total_amount,
        sum(case when payment_method = 'credit_card' then amount else 0 end) over (partition by order_id) as credit_card_amount,
        sum(case when payment_method = 'coupon' then amount else 0 end) over (partition by order_id) as coupon_amount,
        sum(case when payment_method = 'bank_transfer' then amount else 0 end) over (partition by order_id) as bank_transfer_amount,
        sum(case when payment_method = 'gift_card' then amount else 0 end) over (partition by order_id) as gift_card_amount
    from {{ ref('stg_payments') }}
),

distinct_payments as (
    select distinct
        order_id,
        total_amount,
        credit_card_amount,
        coupon_amount,
        bank_transfer_amount,
        gift_card_amount
    from payments
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    coalesce(p.credit_card_amount, 0) as credit_card_amount,
    coalesce(p.coupon_amount, 0) as coupon_amount,
    coalesce(p.bank_transfer_amount, 0) as bank_transfer_amount,
    coalesce(p.gift_card_amount, 0) as gift_card_amount,
    coalesce(p.total_amount, 0) as amount
from orders o
left join distinct_payments p on o.order_id = p.order_id