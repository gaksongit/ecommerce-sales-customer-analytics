SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS order_share_pct
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN order_status IN ('Cancelled', 'Returned') THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS exception_rate_pct
FROM orders;

SELECT
    o.payment_method,
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
GROUP BY o.payment_method
ORDER BY revenue DESC;

WITH order_sizes AS (
    SELECT
        order_id,
        SUM(quantity) AS total_items
    FROM order_items
    GROUP BY order_id
)

SELECT
    ROUND(AVG(total_items), 2) AS avg_items_per_order,
    MIN(total_items) AS min_items_per_order,
    MAX(total_items) AS max_items_per_order
FROM order_sizes;

WITH order_sizes AS (
    SELECT
        order_id,
        SUM(quantity) AS total_items
    FROM order_items
    GROUP BY order_id
)

SELECT
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY total_items)::numeric,
        2
    ) AS median_items_per_order
FROM order_sizes;

WITH order_sizes AS (
    SELECT
        order_id,
        SUM(quantity) AS total_items
    FROM order_items
    GROUP BY order_id
)

SELECT
    CASE
        WHEN total_items <= 3 THEN '1-3 items'
        WHEN total_items <= 6 THEN '4-6 items'
        WHEN total_items <= 10 THEN '7-10 items'
        ELSE '11+ items'
    END AS order_size_group,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS order_share_pct
FROM order_sizes
GROUP BY order_size_group
ORDER BY MIN(total_items);

SELECT
    o.order_status,
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
GROUP BY o.order_status
ORDER BY average_order_value DESC;

SELECT
    ROUND(
        SUM(
            CASE
                WHEN o.order_status IN ('Completed', 'Shipped')
                THEN oi.quantity
                     * oi.unit_price
                     * (1 - oi.discount_pct / 100.0)
                ELSE 0
            END
        ),
        2
    ) AS realized_revenue,
    ROUND(
        SUM(
            CASE
                WHEN o.order_status IN ('Cancelled', 'Returned')
                THEN oi.quantity
                     * oi.unit_price
                     * (1 - oi.discount_pct / 100.0)
                ELSE 0
            END
        ),
        2
    ) AS lost_or_reversed_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;

    SELECT
    payment_method,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN order_status IN ('Cancelled', 'Returned')
            THEN 1
            ELSE 0
        END
    ) AS exception_orders,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN order_status IN ('Cancelled', 'Returned')
                THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS exception_rate_pct
FROM orders
GROUP BY payment_method
ORDER BY exception_rate_pct DESC;

SELECT
    o.payment_method,
    COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_status IN ('Completed', 'Shipped')
    ) AS successful_orders,
    ROUND(
        SUM(
            CASE
                WHEN o.order_status IN ('Completed', 'Shipped')
                THEN oi.quantity
                     * oi.unit_price
                     * (1 - oi.discount_pct / 100.0)
                ELSE 0
            END
        ),
        2
    ) AS realized_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.payment_method
ORDER BY realized_revenue DESC;

SELECT
    oi.discount_pct,
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
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY oi.discount_pct
ORDER BY oi.discount_pct;

SELECT
    oi.discount_pct,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100.0)
        )
        / COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM order_items oi
GROUP BY oi.discount_pct
ORDER BY oi.discount_pct;

SELECT
    discount_pct,
    COUNT(*) AS order_lines,
    SUM(quantity) AS units_sold,
    ROUND(
        AVG(
            quantity
            * unit_price
            * (1 - discount_pct / 100.0)
        ),
        2
    ) AS avg_line_value
FROM order_items
GROUP BY discount_pct
ORDER BY discount_pct;  