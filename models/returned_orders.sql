{{
  config(
    materialized = 'table',
    )
}}

select
    order_id,
    customer_id,
    order_date,
    status,
    amount,
    credit_card_amount,
    coupon_amount,
    bank_transfer_amount,
    gift_card_amount
from {{ ref('orders') }}
where status in ('return_pending', 'returned')