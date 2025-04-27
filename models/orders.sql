{{
  config(
    materialized='incremental',
    unique_key='order_id'
  )
}}

WITH orders AS (
    SELECT * FROM {{ source('elementary_tutorial', 'raw_orders') }}
    {% if is_incremental() %}
    WHERE order_date > (SELECT MAX(order_date) FROM {{ this }})
    {% endif %}
),

order_payments AS (
    SELECT * FROM {{ source('elementary_tutorial', 'raw_payments') }}
),

final AS (
    SELECT
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,
        SUM(CASE WHEN order_payments.status = 'success' THEN order_payments.amount END) as amount

    FROM orders
    LEFT JOIN order_payments USING (order_id)
    GROUP BY 1, 2, 3, 4
)

SELECT * FROM final