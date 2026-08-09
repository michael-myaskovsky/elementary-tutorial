with payments as (
    select
        order_id,
        sum(case when status = 'success' then amount end) as amount
    from {{ ref('stg_payments') }}
    group by 1
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        coalesce(payments.amount, 0) as amount
    from {{ ref('stg_orders') }} as orders
    left join payments on orders.order_id = payments.order_id
)

select * from final