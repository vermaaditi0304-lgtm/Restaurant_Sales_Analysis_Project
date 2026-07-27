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
    
    -- 1: View first 10 transactions
SELECT * FROM transactions LIMIT 10;

-- 2: Total number of orders
SELECT COUNT(*) AS total_orders FROM transactions;

-- 3: Total revenue
SELECT SUM(total_amt) AS total_revenue FROM transactions;

-- 4: Unique categories
SELECT DISTINCT category FROM transactions;

-- 5: Orders per category
SELECT category, COUNT(*) AS order_count
FROM transactions
GROUP BY category
ORDER BY order_count DESC;

-- 6: Total revenue per category
SELECT 
    category,
    SUM(total_amt) AS total_revenue,
    COUNT(*) AS total_orders,
    ROUND(AVG(total_amt), 2) AS avg_order_value
FROM transactions
GROUP BY category
ORDER BY total_revenue DESC;

-- 7: Revenue by payment method
SELECT 
    payment_method,
    COUNT(*) AS transactions,
    SUM(total_amt) AS revenue,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM transactions), 1) AS pct_share
FROM transactions
GROUP BY payment_method
ORDER BY revenue DESC;

-- 8: Top 10 customers by total spending (requires JOIN)
SELECT 
    t.customer_id,
    c.city,
    c.age_group,
    SUM(t.total_amt) AS total_spent,
    COUNT(t.order_id) AS total_orders
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.city, c.age_group
ORDER BY total_spent DESC
LIMIT 10;

-- 9: Revenue by city
SELECT 
    c.city,
    SUM(t.total_amt) AS revenue,
    COUNT(t.order_id) AS orders
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.city
ORDER BY revenue DESC;

-- 10: Revenue by age group
SELECT 
    c.age_group,
    SUM(t.total_amt) AS revenue,
    COUNT(t.order_id) AS orders,
    ROUND(AVG(t.total_amt), 2) AS avg_order
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.age_group
ORDER BY revenue DESC;