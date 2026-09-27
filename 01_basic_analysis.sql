SELECT COUNT(*) AS total_orders
FROM orders;

SELECT
    ROUND(
        SUM(quantity * unit_price * (1 - discount_pct / 100.0)),
        2
    ) AS total_revenue
FROM order_items;

SELECT
    ROUND(
        SUM(quantity * unit_price * (1 - discount_pct / 100.0))
        / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM order_items;

SELECT
    c.category_name,
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)),
        2
    ) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)),
        2
    ) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name
ORDER BY revenue DESC
LIMIT 10;

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) AS number_of_orders,
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)),
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
ORDER BY total_spent DESC
LIMIT 10;

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)

SELECT
    COUNT(*) FILTER (WHERE order_count = 1) AS one_time_customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE order_count > 1) / COUNT(*),
        2
    ) AS repeat_customer_rate
FROM customer_orders;

SELECT
    DATE_TRUNC('month', o.order_date)::date AS month,
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)),
        2
    ) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY month
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
        100.0 * (
            revenue
            - LAG(revenue, 12) OVER (ORDER BY month)
        )
        / LAG(revenue, 12) OVER (ORDER BY month),
        2
    ) AS yoy_growth_pct
FROM monthly_revenue
ORDER BY month;

SELECT
    ROUND(
        SUM(
            oi.quantity
            * (
                oi.unit_price * (1 - oi.discount_pct / 100.0)
                - p.cost
            )
        ),
        2
    ) AS gross_profit
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id;

    SELECT
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
    ) AS gross_profit_margin_pct
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id;

    SELECT
    c.category_name,
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
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY gross_profit DESC;

WITH product_revenue AS (
    SELECT
        c.category_name,
        p.product_id,
        p.product_name,
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        ) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN categories c
        ON p.category_id = c.category_id
    GROUP BY
        c.category_name,
        p.product_id,
        p.product_name
),

ranked_products AS (
    SELECT
        category_name,
        product_id,
        product_name,
        ROUND(revenue, 2) AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY category_name
            ORDER BY revenue DESC
        ) AS product_rank
    FROM product_revenue
)

SELECT
    category_name,
    product_id,
    product_name,
    revenue,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY
    category_name,
    product_rank;