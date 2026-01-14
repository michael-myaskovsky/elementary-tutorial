WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
),

customer_orders_and_payments AS (
    SELECT
        orders.customer_id,
        COUNT(DISTINCT orders.order_id) AS number_of_orders,
        COALESCE(SUM(payments.amount), 0) AS total_amount
    FROM orders
    LEFT JOIN payments ON orders.order_id = payments.order_id
    GROUP BY orders.customer_id
),

final AS (
    SELECT
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        COALESCE(customer_orders_and_payments.number_of_orders, 0) AS number_of_orders,
        COALESCE(customer_orders_and_payments.total_amount, 0) AS customer_lifetime_value
    FROM customers
    LEFT JOIN customer_orders_and_payments ON customers.customer_id = customer_orders_and_payments.customer_id
)

SELECT * FROM final