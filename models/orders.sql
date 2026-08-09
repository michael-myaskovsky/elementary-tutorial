{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with orders as (

    select
        order_id,
        customer_id,
        order_date,
        status
    from {{ ref('stg_orders') }}

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

    -- Using LEFT JOIN to keep all orders, even those without payments
    left join order_payments
        on orders.order_id = order_payments.order_id

)

select * from final

/*
Optimization suggestions:
1. Consider materializing this model as a table if it's frequently queried.
2. If supported by your data warehouse, consider partitioning by order_date
   and clustering by customer_id or order_id for improved query performance.
*/
