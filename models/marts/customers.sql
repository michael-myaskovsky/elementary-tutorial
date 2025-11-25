-- This model creates a comprehensive view of customer data,
-- including order and payment information.

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date
    FROM {{ ref('stg_orders') }}
    WHERE status = 'completed'  -- Only consider completed orders
    GROUP BY customer_id
),

customer_payments AS (
    SELECT
        customer_id,
        SUM(amount) AS total_amount,
        AVG(amount) AS avg_amount
    FROM {{ ref('stg_payments') }}
    WHERE amount > 0  -- Exclude non-positive payments
    GROUP BY customer_id
),

customer_signup_dates AS (
    SELECT 
        customer_id,
        signup_date
    FROM {{ ref('stg_signups') }}
)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    csd.signup_date,
    co.total_orders,
    co.first_order_date,
    co.last_order_date,
    COALESCE(cp.total_amount, 0) AS total_amount,
    COALESCE(cp.avg_amount, 0) AS avg_amount
FROM {{ ref('stg_customers') }} c
LEFT JOIN customer_orders co ON c.customer_id = co.customer_id
LEFT JOIN customer_payments cp ON c.customer_id = cp.customer_id
LEFT JOIN customer_signup_dates csd ON c.customer_id = csd.customer_id