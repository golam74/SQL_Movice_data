select * from album
-- Q1 -who is the senior most employee on based on job title
select * from employee
order by levels desc
limit 1
--Q2 which countries have the most Invoices?
select * from invoice

select billing_country, count (*)as C 
from invoice
group by  billing_country
order by C desc
--Q3 What are top 3 values of total invoice
select total, billing_city from invoice
order by total desc
limit 3
--Q4: Which city has the best Customers? 
--We would like to throw a promothional Music Festival in the city we made the most money.
--write a query that returns one city that has the highest sum of invoice totlas.
--Return both the city name & sum of all invoice totals
select * from invoice
select sum(total) as total_invoice, billing_city 
from invoice
group by billing_city
order by  total_invoice desc
limit 1
--Q5 Who is the best customer?
--The customer who has spent the most money will be declared the best customer.
--Write a query that returns the person who has spent the most money
select Customer.customer_id,customer.first_name,customer.last_name, sum(invoice.total) as total
from Customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

Question Set 2 - Moderate
select * from genre
--Q1: Write query to return the email, first name, last name, & Genre or all Rock Music listeners.
--Return your list ordered alphabetically by email starting with A
select customer.email, Customer.first_name,Customer.last_name from customer
join invoice on Customer.Customer_id = invoice.Customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id 
where track_id in (
	select track_id  from track
	join genre on track.genre_id = genre.genre_id
	Where genre.name like 'Rock'
)
order by email

--Q2: Let's invite the artists who have written the most rock music in our dateset.
--write a query that returns the artist name and total track count of the top 10 rock bands
select artist.artist_id, artist.name,count(artist.artist_id) as number_of_song
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.album_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_song desc
limit 10


--Q3: Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track.
--Order by the song length with the longest songs listed first.
select name,milliseconds from track
where milliseconds > (
	select avg(milliseconds)as avg_track_length
	from track)
order by milliseconds desc


Question Set 3 - Advance
--Q1: find how much amount spent by each customer on arists?
-- Query to return customer name, artist name and total spent
WITH best_selling_artist AS (
    SELECT 
        artist.artist_id AS artist_id, 
        artist.name AS artist_name,
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY 1, 2  -- Include artist_name in GROUP BY
    ORDER BY 3 DESC
    LIMIT 1
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name, 
    bsa.artist_name,
    round(SUM(il.unit_price * il.quantity):: numeric,2) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC;
--Q2 We went to find out the most popular music Genre for each country.
--We determine the most popular genre as the genre with the highest amount of purchases.
--Write a query that returns each country along with the top Genre.
--For countries where the maximum number of prchases is shared return all genres.
with recursive
	sales_per_country as(
	select count (*) as purchases_per_genre,customer.country,genre.name,genre.genre_id
from invoice_line
join invoice on invoice.invoice_id =invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2
),
max_genre_per_country as (select Max (purchases_per_genre) as max_genre_number, country
from sales_per_country
group by 2
order by 2)
select sales_per_country. *
from sales_per_country
join max_genre_per_country on sales_per_country.country = max_genre_per_country.country
where sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number

--Q3: Write a query that determines the customer that has spent the most on music for each country
--Write a query that returns the country along with the top customer and how much they spent.
--For countries where the top customer and how much they spent.
--For countries where the top amount spent is shared, provide all customers who spent this amount
with recursive
	customer_with_country as(
		select customer.customer_id,first_name,last_name,billing_country,sum (total)as total_spending
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 2,3 desc),
	country_max_spending as(

		select billing_country,max(total_spending) as max_spending
		from customer_with_country
		group by billing_country)
		
select cc.billing_country,cc.total_spending,cc.first_name,cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;


