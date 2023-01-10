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

