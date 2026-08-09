with orders as (
    select order_id, customer_id, order_date, status from USAGE_DB.PUBLIC.stg_orders
),
payments as (
    select 
        order_id,
        sum(case when payment_method = 'credit_card' then amount else 0 end) as credit_card_amount,
        sum(case when payment_method = 'coupon' then amount else 0 end) as coupon_amount,
        sum(case when payment_method = 'bank_transfer' then amount else 0 end) as bank_transfer_amount,
        sum(case when payment_method = 'gift_card' then amount else 0 end) as gift_card_amount,
        sum(amount) as total_amount
    from USAGE_DB.PUBLIC.stg_payments
    group by order_id
),
final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        coalesce(payments.credit_card_amount, 0) as credit_card_amount,
        coalesce(payments.coupon_amount, 0) as coupon_amount,
        coalesce(payments.bank_transfer_amount, 0) as bank_transfer_amount,
        coalesce(payments.gift_card_amount, 0) as gift_card_amount,
        coalesce(payments.total_amount, 0) as amount
    from orders
    left join payments
        on orders.order_id = payments.order_id
)
select * from final