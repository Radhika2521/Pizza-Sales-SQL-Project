create database pizzahut;

create table orders (
order_id int NOT NULL,
order_date date NOT NULL,
order_time time NOT NULL,
primary key (order_id));
ALTER TABLE orders
RENAME COLUMN order_data TO order_date;

create table order_details (
order_details_id int NOT NULL,
order_id int NOT NULL,
pizza_id text NOT NULL,
quantity int NOT NULL,
primary key (order_details_id));

-- Retrieve the total number of orders placed
SELECT count(order_id) as total_orders FROM orders

-- Calculate the total revenue generated from pizza sales
SELECT 
round(sum(order_details.quantity * pizzas.price),2) as total_revenue
FROM order_details JOIN pizzas
ON pizzas. pizza_id = order_details.pizza_id

-- Identify the highest priced pizza
SELECT pizza_types.name, pizzas.price
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC LIMIT 1

-- Identify the most common pizza size ordered (count of quantity)
SELECT pizzas.size, count(order_details.order_details_id) as order_count
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1

-- List the top 5 most common pizza type along with their quantities
SELECT pizza_types.name, sum(order_details.quantity) as quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC 
LIMIT 5

-- Join the necessary tables to find the total quantity of each pizza category ordered
SELECT pizza_types.category, sum(order_details.quantity) as quantity
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types 
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category

-- Determine the distribution of orders by hour of the day 
SELECT hour(order_time) as hour, count(order_id) as order_count
FROM orders
GROUP BY hour(order_time)
ORDER BY order_count DESC

-- Join the relevant tables to find the categorywise distribution of pizzas
SELECT category,  count(name) as count
FROM pizza_types
GROUP BY category

-- Group the orders by date and calculate the average number of pizzas ordered per day
SELECT round(avg(quantity),0) AS avg_pizzas_ordered_per_day FROM 
(SELECT orders.order_date, sum(order_details.quantity) as quantity
FROM orders 
JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) as order_quantity

-- Determine the top 3 most ordered pizza types based on the revenue
SELECT pizza_types.name, SUM(pizzas.price * order_details.quantity) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name 
ORDER BY revenue DESC 
LIMIT 3

-- Calculate the percentage contribution of each pizza type to total revenue
-- SELECT pizza_types.category, ROUND(SUM(pizzas.price * order_details.quantity) /
-- SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS total_sales
-- FROM order_details
-- JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100, 2) AS revenue
-- FROM pizza_types JOIN pizzas
-- ON pizza_types.pizza_type_id = pizzas.pizza_type_id
-- JOIN order_details 
-- ON pizzas.pizza_id = order_details.pizza_id
-- GROUP BY pizza_types.category
-- ORDER BY revenue DESC 

-- Analyze the cumulative revenue generated over time
SELECT order_date, SUM(revenue) OVER (ORDER BY order_date) AS cum_rev
FROM
(SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS revenue
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders 
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS sales

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT name, revenue
FROM
(SELECT name, category, revenue,
rank() over (PARTITION BY category ORDER BY revenue DESC) AS rn
FROM 
(SELECT pizza_types.name, pizza_types.category, SUM(pizzas.price * order_details.quantity) AS revenue
FROM pizza_types JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name, pizza_types.category) AS a) AS b
WHERE rn <= 3


