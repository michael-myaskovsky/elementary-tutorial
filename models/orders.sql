WITH
stg_orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),
stg_payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
),
order_payments AS (
    SELECT
        order_id,
        SUM(amount) AS total_amount,
        -- Optimized payment method summation using conditional aggregation
        SUM(CASE WHEN payment_method = 'credit_card' THEN amount ELSE 0 END) AS credit_card_amount,
        SUM(CASE WHEN payment_method = 'coupon' THEN amount ELSE 0 END) AS coupon_amount,
        SUM(CASE WHEN payment_method = 'bank_transfer' THEN amount ELSE 0 END) AS bank_transfer_amount,
        SUM(CASE WHEN payment_method = 'gift_card' THEN amount ELSE 0 END) AS gift_card_amount
    FROM stg_payments
    GROUP BY order_id
),
final AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        p.total_amount,
        p.credit_card_amount,
        p.coupon_amount,
        p.bank_transfer_amount,
        p.gift_card_amount
    FROM stg_orders o
    LEFT JOIN order_payments p ON o.order_id = p.order_id
)
SELECT * FROM final