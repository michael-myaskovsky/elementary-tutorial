-- Optimized orders model

{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with stg_orders as (
    select * from {{ ref('stg_orders') }}
),

stg_payments as (
    select * from {{ ref('stg_payments') }}
),

order_payments as (
    select
        order_id,
        {% for payment_method in payment_methods -%}
        sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) as {{ payment_method }}_amount,
        {% endfor -%}
        sum(amount) as total_amount
    from stg_payments
    group by order_id
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        {% for payment_method in payment_methods -%}
        coalesce(op.{{ payment_method }}_amount, 0) as {{ payment_method }}_amount,
        {% endfor -%}
        coalesce(op.total_amount, 0) as amount
    from stg_orders o
    left join order_payments op
        on o.order_id = op.order_id
)

select * from final