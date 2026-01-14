WITH customers AS (
    SELECT * FROM {{ source('elementary_tutorial', 'customers') }}
),

orders AS (
    SELECT * FROM {{ source('elementary_tutorial', 'orders') }}
),

payments AS (
    SELECT * FROM {{ source('elementary_tutorial', 'payments') }}
),

signups AS (
    SELECT * FROM {{ source('elementary_tutorial', 'signups') }}
),

customer_orders AS (
    SELECT
        customer_id,
        MIN(created_at) AS first_order_timestamp,
        MAX(created_at) AS most_recent_order_timestamp,
        COUNT(*) AS number_of_orders
    FROM orders
    GROUP BY customer_id
),

customer_payments AS (
    SELECT
        orders.customer_id,
        SUM(amount) AS total_amount
    FROM payments
    LEFT JOIN orders ON
         payments.order_id = orders.order_id
    GROUP BY orders.customer_id
),

final AS (
    SELECT
        customers.customer_id,
        customers.customer_first_name,
        customer_orders.first_order_timestamp,
        customer_orders.most_recent_order_timestamp,
        signups.signup_timestamp,
        COALESCE(customer_orders.number_of_orders, 0) AS number_of_orders,
        customer_payments.total_amount AS customer_lifetime_value
    FROM customers
    LEFT JOIN customer_orders
        ON customers.customer_id = customer_orders.customer_id
    LEFT JOIN customer_payments
        ON customers.customer_id = customer_payments.customer_id
    LEFT JOIN signups
        ON customers.customer_id = signups.customer_id
)

SELECT * FROM final