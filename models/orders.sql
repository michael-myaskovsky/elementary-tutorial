{{ config(materialized='table') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
)

SELECT
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.status,
    COALESCE(SUM(payments.amount), 0) AS amount
FROM orders
INNER JOIN payments ON orders.order_id = payments.order_id
GROUP BY 1, 2, 3, 4
