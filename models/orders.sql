{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

-- Consider partitioning by order_date if the date range is wide
with orders as (
    select * from {{ ref('stg_orders') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

aggregated_payments as (
    select
        order_id,
        {% for payment_method in payment_methods -%}
        sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) as {{ payment_method }}_amount,
        {% endfor -%}
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
        {% for payment_method in payment_methods -%}
        coalesce(aggregated_payments.{{ payment_method }}_amount, 0) as {{ payment_method }}_amount,
        {% endfor -%}
        coalesce(aggregated_payments.total_amount, 0) as amount
    from orders
    inner join aggregated_payments
        on orders.order_id = aggregated_payments.order_id
)

select * from final