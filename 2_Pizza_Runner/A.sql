--1, How many pizzas were ordered?
SELECT COUNT(pizza_id) FROM customer_orders;

--2, How many unique customer orders were made?
SELECT
    customer_id,
    COUNT(DISTINCT order_id)
FROM customer_orders
GROUP BY customer_id;

--3, How many successful orders were delivered by each runner?
SELECT 
    runner_id,
    COUNT(order_id)
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
