/*Q1 Who is the senior most employee? 
SELECT * FROM employee
ORDER BY levels desc
limit 1*/

/* Which country has the most invoices? 
select count(*) as c, billing_country 
from invoice
group by billing_country
order by c desc*/

/* What are the top 3 values of total invoices?
select * from invoice
order by total desc
limit 3*/

/* Q4: Which city has the best customers? We would like to throw a promotional 
Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals 

select sum(total) as sum_of_all_invoices_total, billing_city from invoice
group by billing_city
order by sum_of_all_invoices_total desc */

/*Q5: Who is the best customer? The customer who has spent the most money 
will be declared the best customer. Write a query that returns the person 
who has spent the most money
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 3*/ 

/*MODERATE
Q1: Write query to return the email, first name, last name, & Genre of 
all Rock Music listeners. Return your list ordered alphabetically by email 
starting with A*/

/*select distinct email, first_name, last_name, genre.name
from customer
join invoice on customer.customer_id = invoice.invoice_id
join invoice_line on  invoice.invoice_id = invoice_line.invoice_id 
join track on  invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
order by email*/

/*SELECT DISTINCT email,first_name, last_name
FROM customer 
JOIN invoice ON customer.customer_id = invoice.customer_id 
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id 
WHERE track_id IN( 
	SELECT track_id FROM track 
	JOIN genre ON track.genre_id = genre.genre_id 
	WHERE genre.name LIKE 'Rock'
	)
	order by email;*/

/*Q2: Let's invite the artists who have written the most rock music 
in our dataset. Write a query that returns the Artist 
name ard_total track count of the top 10 rock bands*/

/*select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs 
from track
join album on album.album_id = track.album_id 
join artist on artist.artist_id = album.artist_id
join genre on track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10
*/
/*Q3: Return all the track names that have a song length longer than 
the average song length. Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first.*/
/*select name, milliseconds 
from track
where milliseconds > (
	select avg(milliseconds) as avg_ln 
	from track)
order by milliseconds desc*/

/*ADVANCE
Q1: Find how much amount spent by each customer on artists? Write a query 
to return customer name, artist name and total spent*/
/*
SELECT customer.customer_id, artist.name, customer.FIRST_NAME, sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
from invoice
JOIN customer ON customer.customer_id = invoice.customer_id 
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id 
join track on  invoice_line.track_id = track.track_id
join album on album.album_id = track.album_id 
join artist on artist.artist_id = album.artist_id
group by 1,2
order by 4 desc
*/

/*SELECT artist.name, c.FIRST_NAME, total_spent
FROM (
    SELECT customer.FIRST_NAME, sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
    FROM customer
    join invoice on customer.customer_id = invoice.customer_id
	JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id 
	join track on  invoice_line.track_id = track.track_id
	join album on album.album_id = track.album_id 
	join artist on artist.artist_id = album.artist_id
	GROUP BY customer.FIRST_NAME
	) as c
ORDER BY total_spent DESC;*/
 
/*OR*/

/*WITH best_selling_artist AS (  
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
	FROM invoice_line 
	JOIN track ON track.track_id = invoice_line.track_id 
	JOIN album ON album.album_id = track.album_id 
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC 
	limit 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price * il.quantity)
FROM invoice i 
JOIN customer c ON c.customer_id = i.customer_id 
JOIN invoice_line il ON il.invoice_id = i.invoice_id 
JOIN track t ON t.track_id = il.track_id 
join album alb ON alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc */

/*Q2 We want to find out the most popular music Genre for each country. We 
determine the most popular genre as the genre with the highest amount of 
purchases. Write a query that returns each country along with the top Genre. For 
countries where the maximum number of purchases is shared return all Genre*/


/* Method 1: Using CTE */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* Method 2: : Using Recursive */

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: using CTE */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1


/* Method 2: Using Recursive */

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;


