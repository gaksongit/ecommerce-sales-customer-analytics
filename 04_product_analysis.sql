SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS units_sold,
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
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name
ORDER BY revenue DESC;

WITH product_metrics AS (
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        SUM(oi.quantity) AS units_sold,
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
    FROM products p
    JOIN categories c
        ON p.category_id = c.category_id
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name
)

SELECT
    product_id,
    product_name,
    category_name,
    units_sold,
    ROUND(revenue, 2) AS revenue,
    ROUND(gross_profit, 2) AS gross_profit,
    ROUND(
        100.0 * gross_profit / revenue,
        2
    ) AS gross_margin_pct
FROM product_metrics
WHERE revenue >= 200000
  AND 100.0 * gross_profit / revenue < 25
ORDER BY revenue DESC;

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS units_sold,
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
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name
HAVING
    SUM(
        oi.quantity
        * oi.unit_price
        * (1 - oi.discount_pct / 100.0)
    ) >= 150000
AND
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
    ) >= 40
ORDER BY gross_profit DESC;

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS units_sold,
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
    ) AS gross_profit
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name
ORDER BY revenue ASC
LIMIT 15;

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS units_sold,
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
        / SUM(oi.quantity),
        2
    ) AS avg_selling_price
FROM products p
JOIN categories c
    ON p.category_id = c.category_id
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name
ORDER BY avg_selling_price ASC
LIMIT 15;

WITH category_revenue AS (
    SELECT
        c.category_name,
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
    GROUP BY c.category_name
)

SELECT
    category_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100.0 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct
FROM category_revenue
ORDER BY revenue DESC;