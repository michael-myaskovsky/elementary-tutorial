-- Optimized orders model
WITH orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        status
    FROM {{ ref('stg_orders') }}
),

order_payments AS (
    SELECT
        order_id,
        SUM(CASE WHEN status = 'success' THEN amount END) as amount,
        COUNT(CASE WHEN status = 'success' THEN 1 END) as successful_payments
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id
)

SELECT
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.status,
    COALESCE(order_payments.amount, 0) as amount,
    order_payments.successful_payments,
    CASE
        WHEN orders.status = 'completed' AND order_payments.successful_payments > 0 THEN true
        ELSE false
    END as is_completed
FROM orders
LEFT JOIN order_payments USING (order_id)