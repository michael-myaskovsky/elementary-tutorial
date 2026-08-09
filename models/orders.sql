{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with orders as (
    select * from {{ ref('stg_orders') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

order_payments as (
    select *
    from payments
    pivot (
        sum(amount)
        for payment_method in ({{ payment_methods | join(', ') }})
    ) as p (order_id, {{ payment_methods | map('lower') | map('replace', ' ', '_') | map('add', '_amount') | join(', ') }}, total_amount)
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        {% for payment_method in payment_methods -%}
        coalesce(order_payments.{{ payment_method }}_amount, 0) as {{ payment_method }}_amount,
        {% endfor -%}
        coalesce(order_payments.total_amount, 0) as amount
    from orders
    left join order_payments
        on orders.order_id = order_payments.order_id
)

select * from final