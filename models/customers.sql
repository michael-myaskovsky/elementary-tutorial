with customers as (
    select customer_id, first_name, last_name
    from {{ ref('stg_customers') }}
),

orders as (
    select customer_id, order_id, order_date
    from {{ ref('stg_orders') }}
),

payments as (
    select order_id, amount
    from {{ ref('stg_payments') }}
),

signups as (
    select customer_id, customer_email, signup_date
    from {{ ref('stg_signups') }}
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        min(o.order_date) as first_order,
        max(o.order_date) as most_recent_order,
        count(o.order_id) as number_of_orders,
        coalesce(sum(p.amount), 0) as customer_lifetime_value,
        s.customer_email,
        s.signup_date
    from customers c
    left join orders o on c.customer_id = o.customer_id
    left join payments p on o.order_id = p.order_id
    left join signups s on c.customer_id = s.customer_id
    group by c.customer_id, c.first_name, c.last_name, s.customer_email, s.signup_date
)

select * from final