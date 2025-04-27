with orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select * from {{ ref('stg_payments') }}

),

completed_payments as (

    select 
        order_id,
        {% for payment_method in ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}
        sum(case when payment_method = '{{payment_method}}' then amount else 0 end) as {{payment_method}}_amount,
        {% endfor %}
        sum(amount) as total_amount
    from payments
    where status = 'success'
    group by order_id

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        completed_payments.total_amount as amount,
        {% for payment_method in ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}
        completed_payments.{{payment_method}}_amount,
        {% endfor %}
        orders.created_at,
        orders.updated_at

    from orders
    left join completed_payments on orders.order_id = completed_payments.order_id
    where orders.status not in ('pending', 'canceled')  -- Added WHERE clause to filter out unnecessary rows
)

select * from final