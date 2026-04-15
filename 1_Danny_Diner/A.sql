-- 1, What is the total amount each customer spent at the restaurant?
SELECT 
    s.customer_id,
    SUM(price) AS total
FROM sales AS s
INNER JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 2, How many days has each customer visited the restaurant?
SELECT 
    customer_id,
    COUNT(DISTINCT order_date) AS total_days
FROM sales
GROUP BY customer_id;

-- 3, What was the first item from the menu purchased by each customer?
WITH ranked AS (
    SELECT
        customer_id,
        product_name,
        order_date,
        ROW_NUMBER() OVER(
            PARTITION BY customer_id
            ORDER BY order_date, s.product_id
        ) AS ranking
    FROM sales AS s
    JOIN menu AS m 
    ON s.product_id = m.product_id
)
SELECT 
    customer_id,
    product_name,
    order_date
FROM ranked
WHERE ranking = 1;

-- 4, What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH count_purchase AS (
    SELECT
        m.product_name,
        COUNT(s.product_id) AS total
    FROM sales AS s
    JOIN menu AS m
    ON m.product_id = s.product_id
    GROUP BY m.product_name
)
SELECT 
    product_name,
    total
FROM count_purchase
ORDER BY total DESC
LIMIT 1;

-- 5, Which item was the most popular for each customer?
WITH count_purchase AS (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(s.product_id) AS total,
        RANK() OVER(
            PARTITION BY s.customer_id
            ORDER BY COUNT(s.product_id) DESC
        ) AS ranking
    FROM sales AS s
    JOIN menu AS m
    ON m.product_id = s.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT 
    customer_id,
    product_name,
    total
FROM count_purchase
WHERE ranking = 1;

-- 6, Which item was purchased first by the customer after they became a member?
WITH ranked AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        mm.join_date,
        ROW_NUMBER() OVER(
            PARTITION BY s.customer_id
            ORDER BY s.order_date
        ) AS ranking
    FROM sales AS s
    INNER JOIN menu AS m 
    ON s.product_id = m.product_id
    INNER JOIN members AS mm
    ON mm.customer_id = s.customer_id
    WHERE s.order_date >= mm.join_date 
)
SELECT 
    customer_id,
    order_date,
    product_name,
    join_date
FROM ranked
WHERE ranking = 1
ORDER BY 1;


-- 7, Which item was purchased just before the customer became a member?
WITH ranked AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        mm.join_date,
        ROW_NUMBER() OVER(
            PARTITION BY s.customer_id
            ORDER BY s.order_date DESC
        ) AS ranking
    FROM sales AS s
    INNER JOIN menu AS m 
    ON s.product_id = m.product_id
    INNER JOIN members AS mm
    ON mm.customer_id = s.customer_id
    WHERE s.order_date <= mm.join_date 
)
SELECT 
    customer_id,
    order_date,
    product_name,
    join_date
FROM ranked
WHERE ranking = 1
ORDER BY 1;

-- 8, What is the total items and amount spent for each member before they became a member?
SELECT 
    s.customer_id,
    COUNT(s.product_id) AS total_items,
    SUM(m.price) AS total_amt
FROM sales AS s
INNER JOIN menu AS m 
ON m.product_id = s.product_id
INNER JOIN members AS mm
ON mm.customer_id = s.customer_id
WHERE s.order_date < mm.join_date
GROUP BY s.customer_id;

-- 9, If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
    s.customer_id,
    SUM(points) AS total_points
FROM sales AS s
INNER JOIN (
    SELECT
        product_id,
        CASE 
            WHEN product_id = 1 THEN price * 20
            ELSE price * 10 END 
        AS points
    FROM menu 
) AS p
ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 1;