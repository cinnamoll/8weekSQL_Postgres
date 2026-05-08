UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions = 'null' OR exclusions='';

UPDATE customer_orders
SET extras = NULL
WHERE extras = 'null' OR extras='';

UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation='null' or cancellation='';

UPDATE runner_orders
SET pickup_time = NULL
WHERE pickup_time='null';

UPDATE runner_orders
SET distance = NULL
WHERE distance='null';

UPDATE runner_orders
SET duration = NULL
WHERE duration='null';

UPDATE runner_orders
SET duration = NULLIF(REGEXP_REPLACE(duration, '\D', '', 'g'), '')::numeric

UPDATE runner_orders
SET distance = SUBSTRING(distance FROM '[0-9]+\.?[0-9]*')::NUMERIC
WHERE distance IS NOT NULL;

INSERT INTO pizza_recipes (pizza_id, toppings)
SELECT pizza_id, unnest(string_to_array(toppings, ', '))
FROM pizza_recipes;

DELETE FROM pizza_recipes
WHERE LENGTH(toppings) > 2;