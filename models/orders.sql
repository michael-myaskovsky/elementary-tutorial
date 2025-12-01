
with orders as (
    
    select * from {{ ref('stg_orders') }}

),

order_payments as (
    select
        order_id,
        sum(amount) as total_amount,
        sum(amount) filter (where payment_method = 'credit_card') as credit_card_amount,
        sum(amount) filter (where payment_method = 'coupon') as coupon_amount,
        sum(amount) filter (where payment_method = 'bank_transfer') as bank_transfer_amount,
        sum(amount) filter (where payment_method = 'gift_card') as gift_card_amount
    from {{ ref('stg_payments') }}
    group by order_id
),

final as (

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
    
    left join order_payments using (order_id)
)

select * from final
