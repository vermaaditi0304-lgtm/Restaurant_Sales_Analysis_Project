CREATE DATABASE restaurant_data_eda;
USE restaurant_data_eda;

CREATE TABLE transactions (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    category VARCHAR(100),
    item_name VARCHAR(100),
    item_price INTEGER,
    quantity INTEGER,
    total_amt INTEGER,
    order_date DATE,
    payment_method VARCHAR(50),
    ordered_by VARCHAR(20),
    time_of_sale VARCHAR(20)
    );

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    city VARCHAR(50),
    age_group VARCHAR(20)
    );
    
-- 1: Total revenue per category
SELECT category, SUM(total_amt) AS total_revenue, COUNT(*) AS total_orders, ROUND(AVG(total_amt), 2) AS avg_order_value
FROM transactions
GROUP BY category
ORDER BY total_revenue DESC;

-- 2: Revenue by payment method
SELECT payment_method, COUNT(*) AS transactions, SUM(total_amt) AS revenue, 
ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM transactions), 1) AS pct_share
FROM transactions
GROUP BY payment_method
ORDER BY revenue DESC;

-- 3: Revenue by city
SELECT c.city,SUM(t.total_amt) AS revenue, COUNT(t.order_id) AS orders
FROM transactions t
JOIN customers c 
ON t.customer_id = c.customer_id
GROUP BY c.city
ORDER BY revenue DESC;

-- 4: Revenue by age group
SELECT c.age_group, SUM(t.total_amt) AS revenue, COUNT(t.order_id) AS orders, ROUND(AVG(t.total_amt), 2) AS avg_order
FROM transactions t
JOIN customers c 
ON t.customer_id = c.customer_id
GROUP BY c.age_group
ORDER BY revenue DESC;

-- 5: Top 10 customers by total spending
SELECT t.customer_id, c.city, c.age_group, SUM(t.total_amt) AS total_spent, COUNT(t.order_id) AS total_orders
FROM transactions t
JOIN customers c 
ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.city, c.age_group
ORDER BY total_spent DESC
LIMIT 10;

-- 6. Top 10 Revenue-Generating Products
SELECT item_name, SUM(total_amt) AS revenue
FROM transactions
GROUP BY item_name
ORDER BY revenue DESC
LIMIT 10;

-- 7. Lowest 10 Revenue-Generating Products
SELECT item_name, SUM(total_amt) AS revenue
FROM transactions
GROUP BY item_name
ORDER BY revenue
LIMIT 10;

-- 8. Top Product in Each Category (cte + window function)
WITH product_sales AS
(
    SELECT category, item_name, SUM(total_amt) AS revenue,
	DENSE_RANK() OVER (PARTITION BY category ORDER BY SUM(total_amt) DESC) AS rnk
    FROM transactions
    GROUP BY category,item_name
)

SELECT category, item_name, revenue
FROM product_sales
WHERE rnk = 1;

-- 9. Category Revenue Contribution (subquery)
SELECT category, SUM(total_amt) AS revenue, ROUND(SUM(total_amt) * 100 / 
(SELECT SUM(total_amt) FROM transactions),2) AS contribution_percent
FROM transactions
GROUP BY category
ORDER BY contribution_percent DESC;

-- 10. Monthly Revenue Change (window function)
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(total_amt) AS monthly_revenue, 
SUM(SUM(total_amt)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS running_revenue
FROM transactions
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;