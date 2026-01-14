{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with orders as (
    select * from {{ ref('stg_orders') }}
),

payments_aggregated as (
    select
        order_id,
        {% for payment_method in payment_methods -%}
        sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) as {{ payment_method }}_amount,
        {% endfor -%}
        sum(amount) as total_amount
    from {{ ref('stg_payments') }}
    group by order_id
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        {% for payment_method in payment_methods -%}
        coalesce(payments_aggregated.{{ payment_method }}_amount, 0) as {{ payment_method }}_amount,
        {% endfor -%}
        coalesce(payments_aggregated.total_amount, 0) as amount
    from orders
    left join payments_aggregated
        on orders.order_id = payments_aggregated.order_id
)

select * from final