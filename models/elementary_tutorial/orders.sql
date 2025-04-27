{{ config(materialized='table') }}

WITH payments AS (
    SELECT
        order_id,
        SUM(CASE WHEN status = 'success' THEN amount END) as amount
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    COALESCE(p.amount, 0) as amount
FROM {{ ref('stg_orders') }} o
INNER JOIN payments p ON o.order_id = p.order_id