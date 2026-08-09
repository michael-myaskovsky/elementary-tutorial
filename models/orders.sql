{{ config(materialized='table') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
),

order_payments AS (
    SELECT
        order_id,
        SUM(CASE WHEN status = 'success' THEN amount END) AS amount
    FROM payments
    GROUP BY order_id
),

final AS (
    SELECT
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        COALESCE(order_payments.amount, 0) AS amount
    FROM orders
    LEFT JOIN order_payments
        ON orders.order_id = order_payments.order_id
)

SELECT * FROM final

{{ config(
    post_hook=[
        "CREATE INDEX IF NOT EXISTS idx_orders_order_id ON {{ this }}(order_id)",
        "CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON {{ this }}(customer_id)",
        "CREATE INDEX IF NOT EXISTS idx_orders_order_date ON {{ this }}(order_date)"
    ]
) }}