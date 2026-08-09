{{ config(materialized='table') }}

WITH orders AS (
    SELECT 
        order_id,
        customer_id,
        order_date,
        status
    FROM {{ source('jaffle_shop', 'orders') }}
),

payments AS (
    SELECT 
        order_id,
        SUM(CASE WHEN status = 'success' THEN amount END) AS amount
    FROM {{ source('stripe', 'payments') }}
    GROUP BY 1
)

SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    COALESCE(p.amount, 0) AS amount
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id