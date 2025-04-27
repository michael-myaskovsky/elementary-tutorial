{{
  config(
    materialized='incremental',
    unique_key='order_id',
    partition_by={
      'field': 'order_date',
      'data_type': 'date'
    }
  )
}}

with orders as (
    select * from {{ ref('stg_orders') }}

    {% if is_incremental() %}
    where order_date > (select max(order_date) from {{ this }})
    {% endif %}

),

order_payments as (
    select * from {{ ref('stg_payments') }}
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,

        {% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

        {% for payment_method in payment_methods %}
        coalesce(
            sum(case when order_payments.payment_method = '{{ payment_method }}' then amount else 0 end),
            0
        ) as {{ payment_method }}_amount,
        {% endfor %}

        sum(order_payments.amount) as total_amount

    from orders
    left join order_payments using (order_id)
    group by 1, 2, 3, 4
)

select * from final