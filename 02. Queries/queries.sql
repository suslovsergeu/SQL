----- USERS table

-- 1. TOTAL NUMBER OF USERS
SELECT COUNT(*)
FROM users;
--2500 users

-- 2. USERS ACQUIRED BY THE SOURCE
SELECT source,
	   COUNT(id)
FROM users
GROUP BY source
ORDER BY COUNT(id) DESC;

-- 3. USERS DYNAMICS BY YYYY-MM
WITH TMP AS (
	SELECT id,
		   DATE_TRUNC('month', created_at) dt
	FROM users
)
SELECT dt,
	   COUNT(id)
FROM TMP
GROUP BY dt
ORDER BY dt ASC;

-- 4. CUMULATIVE USERS BY YYYY-MM
WITH TMP AS (
	SELECT id,
		   DATE_TRUNC('month', created_at) dt
	FROM users
)
SELECT DISTINCT dt,
	   COUNT(id) OVER (ORDER BY dt)
FROM TMP
ORDER BY dt;

-- 5. USERS WITH GMAIL
SELECT *
FROM users
WHERE email LIKE '%@gmail.com'

----- PRODUCTS table
-- 1. NUMBER OF PRODUCTS BY CATEGORY + AVG RATING
SELECT category,
	   COUNT(id) ttl,
	   ROUND(AVG(rating)::numeric, 2) avg_rating
FROM products
GROUP BY category
ORDER BY COUNT(id) DESC;

-- 2. PRICE BY VENDOR
SELECT vendor,
	   ROUND(AVG(price)::numeric, 2) avg_price
FROM products
GROUP BY vendor
ORDER BY AVG(price) DESC;

----- ORDERS table
-- STAT BY ID
SELECT product_id,
	   ROUND(AVG(total)::numeric, 1),
	   ROUND(AVG(discount)::numeric, 1),
	   ROUND((AVG(discount) / AVG(total))::numeric, 2) prct
FROM orders
GROUP BY product_id
HAVING AVG(discount) > 0
ORDER BY AVG(total) DESC;

----- MIX FROM TABLES
-- 1. ORDERS BY CLIENT
WITH tab AS (
SELECT u.id,
	   u.name,
	   p.title product,
	   ROUND(o.total::numeric, 0) total,
	   o.created_at
FROM users u
	 INNER JOIN orders o ON u.id = o.user_id
	 LEFT JOIN products p ON o.product_id = p.id
ORDER BY u.id, o.created_at
)

SELECT *,
	   LAG(created_at, 1, NULL) OVER (PARTITION BY id ORDER BY created_at) previous_order,
	   created_at - LAG(created_at, 1, NULL) OVER (PARTITION BY id ORDER BY created_at) break
FROM tab