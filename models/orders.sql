{{
  config(
    materialized='table',
    indexes=[
      {'columns': ['order_id']}
    ],
    partition_by={
      'field': 'order_date',
      'data_type': 'date'
    }
  )
}}

-- Consider adding appropriate indexes on the staging tables as well
-- e.g., CREATE INDEX idx_stg_orders_order_id ON {{ source('staging', 'stg_orders') }}(order_id);
-- e.g., CREATE INDEX idx_stg_payments_order_id ON {{ source('staging', 'stg_payments') }}(order_id);

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders' )}}
),

order_payments AS (
    SELECT
        order_id,
        SUM(CASE WHEN payment_method = 'credit_card' THEN amount ELSE 0 END) AS credit_card_amount,
        SUM(CASE WHEN payment_method = 'coupon' THEN amount ELSE 0 END) AS coupon_amount,
        SUM(CASE WHEN payment_method = 'bank_transfer' THEN amount ELSE 0 END) AS bank_transfer_amount,
        SUM(CASE WHEN payment_method = 'gift_card' THEN amount ELSE 0 END) AS gift_card_amount,
        SUM(amount) AS total_amount
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id
)

SELECT
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.status,
    order_payments.credit_card_amount,
    order_payments.coupon_amount,
    order_payments.bank_transfer_amount,
    order_payments.gift_card_amount,
    order_payments.total_amount AS amount
FROM orders
LEFT JOIN order_payments
    ON orders.order_id = order_payments.order_id