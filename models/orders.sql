-- Consider materializing this model as a table if queried frequently
-- Ensure 'order_id' is indexed in both stg_orders and stg_payments
-- Consider partitioning by 'order_date' if it's frequently used in filters or joins

SELECT
    stg_orders.order_id,
    stg_orders.customer_id,
    stg_orders.order_date,
    stg_orders.status,
    SUM(stg_payments.amount) as amount
FROM {{ ref('stg_orders') }} AS stg_orders
LEFT JOIN {{ ref('stg_payments') }} AS stg_payments
    ON stg_orders.order_id = stg_payments.order_id
GROUP BY 1, 2, 3, 4