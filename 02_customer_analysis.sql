WITH customer_summary AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100.0)
            ),
            2
        ) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    *,
    ROUND(total_spent / total_orders, 2) AS avg_order_value
FROM customer_summary
ORDER BY total_spent DESC
LIMIT 20;

WITH customer_summary AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100.0)
            ),
            2
        ) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    customer_id,
    first_name,
    last_name,
    total_orders,
    total_spent,
    CASE
        WHEN total_spent >= 15000 THEN 'High Value'
        WHEN total_spent >= 7000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_summary
ORDER BY total_spent DESC;

WITH customer_summary AS (
    SELECT
        c.customer_id,
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
),

segmented_customers AS (
    SELECT
        customer_id,
        total_spent,
        CASE
            WHEN total_spent >= 15000 THEN 'High Value'
            WHEN total_spent >= 7000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM customer_summary
)

SELECT
    customer_segment,
    COUNT(*) AS number_of_customers,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_customers
FROM segmented_customers
GROUP BY customer_segment
ORDER BY number_of_customers DESC;

WITH customer_summary AS (
    SELECT
        c.customer_id,
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
),

segmented_customers AS (
    SELECT
        customer_id,
        total_spent,
        CASE
            WHEN total_spent >= 15000 THEN 'High Value'
            WHEN total_spent >= 7000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM customer_summary
)

SELECT
    customer_segment,
    COUNT(*) AS number_of_customers,
    ROUND(SUM(total_spent), 2) AS segment_revenue,
    ROUND(
        100.0 * SUM(total_spent)
        / SUM(SUM(total_spent)) OVER (),
        2
    ) AS revenue_share_pct
FROM segmented_customers
GROUP BY customer_segment
ORDER BY segment_revenue DESC;

WITH customer_summary AS (
    SELECT
        c.customer_id,
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
),

segmented_customers AS (
    SELECT
        customer_id,
        total_spent,
        CASE
            WHEN total_spent >= 15000 THEN 'High Value'
            WHEN total_spent >= 7000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM customer_summary
)

SELECT
    customer_segment,
    COUNT(*) AS number_of_customers,
    ROUND(AVG(total_spent), 2) AS avg_customer_value
FROM segmented_customers
GROUP BY customer_segment
ORDER BY avg_customer_value DESC;

WITH customer_rfm AS (
    SELECT
        c.customer_id,
        MAX(o.order_date) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100.0)
            ),
            2
        ) AS monetary
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
)

SELECT
    customer_id,
    last_order_date,
    CURRENT_DATE - last_order_date AS recency_days,
    frequency,
    monetary
FROM customer_rfm
ORDER BY monetary DESC
LIMIT 20;

WITH reference_date AS (
    SELECT MAX(order_date) + 1 AS analysis_date
    FROM orders
),

customer_rfm AS (
    SELECT
        c.customer_id,
        MAX(o.order_date) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ) AS monetary
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
),

rfm_values AS (
    SELECT
        r.customer_id,
        rd.analysis_date - r.last_order_date AS recency_days,
        r.frequency,
        r.monetary
    FROM customer_rfm r
    CROSS JOIN reference_date rd
),

rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        ROUND(monetary, 2) AS monetary,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary
        ) AS m_score

    FROM rfm_values
)

SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    r_score + f_score + m_score AS rfm_total_score
FROM rfm_scores
ORDER BY rfm_total_score DESC, monetary DESC
LIMIT 20;

WITH reference_date AS (
    SELECT MAX(order_date) + 1 AS analysis_date
    FROM orders
),

customer_rfm AS (
    SELECT
        c.customer_id,
        MAX(o.order_date) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ) AS monetary
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
),

rfm_values AS (
    SELECT
        r.customer_id,
        rd.analysis_date - r.last_order_date AS recency_days,
        r.frequency,
        r.monetary
    FROM customer_rfm r
    CROSS JOIN reference_date rd
),

rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary
        ) AS m_score
    FROM rfm_values
),

rfm_segments AS (
    SELECT
        *,
        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 4
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score <= 2
                THEN 'Promising'

            WHEN r_score <= 2
                 AND f_score >= 3
                 AND m_score >= 3
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                THEN 'Hibernating'

            ELSE 'Potential Loyalists'
        END AS rfm_segment
    FROM rfm_scores
)

SELECT
    rfm_segment,
    COUNT(*) AS customers,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary
FROM rfm_segments
GROUP BY rfm_segment
ORDER BY customers DESC;