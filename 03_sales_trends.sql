SELECT
    DATE_TRUNC('month', o.order_date)::date AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ),
        2
    ) AS revenue,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        )
        / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

SELECT
    DATE_TRUNC('month', o.order_date)::date AS month,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ),
        2
    ) AS revenue,
    ROUND(
        SUM(
            oi.quantity
            * (
                oi.unit_price * (1 - oi.discount_pct / 100.0)
                - p.cost
            )
        ),
        2
    ) AS gross_profit,
    ROUND(
        100.0 *
        SUM(
            oi.quantity
            * (
                oi.unit_price * (1 - oi.discount_pct / 100.0)
                - p.cost
            )
        )
        /
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ),
        2
    ) AS gross_margin_pct
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY month
ORDER BY month;

WITH monthly_metrics AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS month,
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ) AS revenue,
        SUM(
            oi.quantity
            * (
                oi.unit_price * (1 - oi.discount_pct / 100.0)
                - p.cost
            )
        ) AS gross_profit
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY month
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(gross_profit, 2) AS gross_profit,
    ROUND(
        100.0 * (
            revenue - LAG(revenue, 12) OVER (ORDER BY month)
        )
        / LAG(revenue, 12) OVER (ORDER BY month),
        2
    ) AS revenue_yoy_pct,
    ROUND(
        100.0 * (
            gross_profit - LAG(gross_profit, 12) OVER (ORDER BY month)
        )
        / LAG(gross_profit, 12) OVER (ORDER BY month),
        2
    ) AS profit_yoy_pct
FROM monthly_metrics
ORDER BY month;

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS month,
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY month
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_3m_avg_revenue
FROM monthly_revenue
ORDER BY month;