-- 🎬 SQL_Movie_Data Analysis
-- Author: Golam Israil

/* =========================================================
   Question Set 1 - Beginner
   ========================================================= */

-- Q1: Who is the senior-most employee (based on job title)?
SELECT *
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2: Which countries have the most invoices?
SELECT billing_country, COUNT(*) AS invoice_count
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC;

-- Q3: What are the top 3 invoice totals?
SELECT total, billing_city
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4: Which city has the highest revenue (best customers)?
-- We want to host a promotional music festival in the city with the most money earned.
SELECT billing_city, SUM(total) AS total_invoice
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1;

-- Q5: Who is the best customer (highest spender)?
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;


/* =========================================================
   Question Set 2 - Moderate
   ========================================================= */

-- Q1: Return email, first name, last name of all Rock music listeners (alphabetically by email).
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE il.track_id IN (
    SELECT t.track_id
    FROM track t
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE g.name = 'Rock'
)
ORDER BY c.email;

-- Q2: Top 10 artists who wrote the most Rock music (by track count).
SELECT a.artist_id, a.name, COUNT(*) AS number_of_songs
FROM track t
JOIN album alb ON alb.album_id = t.album_id
JOIN artist a ON a.artist_id = alb.artist_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY number_of_songs DESC
LIMIT 10;

-- Q3: Return all track names longer than the average song length.
-- Return Name and Milliseconds, ordered by longest first.
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) FROM track
)
ORDER BY milliseconds DESC;


/* =========================================================
   Question Set 3 - Advanced
   ========================================================= */

-- Q1: How much has each customer spent on the top-selling artist?
WITH best_selling_artist AS (
    SELECT 
        a.artist_id,
        a.name AS artist_name,
        SUM(il.unit_price * il.quantity) AS total_sales
    FROM invoice_line il
    JOIN track t ON t.track_id = il.track_id
    JOIN album alb ON alb.album_id = t.album_id
    JOIN artist a ON a.artist_id = alb.artist_id
    GROUP BY a.artist_id, a.name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name,
    ROUND(SUM(il.unit_price * il.quantity)::NUMERIC, 2) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

-- Q2: Most popular music genre for each country (by number of purchases).
WITH sales_per_country AS (
    SELECT 
        c.country,
        g.name AS genre_name,
        g.genre_id,
        COUNT(*) AS purchases_per_genre
    FROM invoice_line il
    JOIN invoice i ON i.invoice_id = il.invoice_id
    JOIN customer c ON c.customer_id = i.customer_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
    GROUP BY c.country, g.name, g.genre_id
),
max_genre_per_country AS (
    SELECT country, MAX(purchases_per_genre) AS max_genre_count
    FROM sales_per_country
    GROUP BY country
)
SELECT spc.country, spc.genre_name, spc.purchases_per_genre
FROM sales_per_country spc
JOIN max_genre_per_country mgpc 
  ON spc.country = mgpc.country 
 AND spc.purchases_per_genre = mgpc.max_genre_count
ORDER BY spc.country;

-- Q3: Top spending customer in each country.
WITH customer_with_country AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country,
        SUM(i.total) AS total_spending
    FROM invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
),
country_max_spending AS (
    SELECT billing_country, MAX(total_spending) AS max_spending
    FROM customer_with_country
    GROUP BY billing_country
)
SELECT 
    cc.billing_country,
    cc.first_name,
    cc.last_name,
    cc.total_spending
FROM customer_with_country cc
JOIN country_max_spending cms 
  ON cc.billing_country = cms.billing_country 
 AND cc.total_spending = cms.max_spending
ORDER BY cc.billing_country;

