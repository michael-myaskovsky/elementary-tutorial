{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select * from {{ ref('stg_payments') }}

),

order_payments as (

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

        order_payments.{{ payment_method }}_amount,

        {% endfor -%}

        order_payments.total_amount as amount

    from orders


    left join order_payments
        on orders.order_id = order_payments.order_id

)

-- Optimization suggestions:
-- 1. Ensure 'order_id' is indexed in both stg_orders and stg_payments tables
-- 2. Consider partitioning the final table by 'order_date' if it spans a wide range of dates

select
    order_id,
    customer_id,
    order_date,
    status,
    {% for payment_method in payment_methods -%}
    {{ payment_method }}_amount,
    {% endfor -%}
    amount
from final