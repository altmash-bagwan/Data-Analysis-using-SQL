-- --------------------------- Music Store Analysis -- ------------------------------------
-- ----------------------------------------------------------------------------------------

CREATE database music_store;

show tables;

rename table album2 to album;

-- 1. Who is the senior most employee based on job title

select *
from music_store.employee
order by levels desc;

-- 2. Which countries have the most Invoices ?

select 
	billing_country,
    count(invoice_id) as no_of_invoice
from music_store.invoice
group by billing_country
order by no_of_invoice desc
limit 3;

-- 3. What are top 3 values of total invoice?

select invoice_id,round(total,2) as total 
from music_store.invoice
order by total desc
limit 3;
 
 /* 4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */

select 
	billing_city as city,
    round(sum(total),2) as revenue
from 
	music_store.invoice
group by city
order by revenue desc 
limit 1;

/* 5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money */

select 
	c.customer_id,
    c.first_name,
    c.last_name,
    round(sum(i.total),2) as revenue 
from customer as c 
join invoice as i on c.customer_id = i.customer_id
group by c.customer_id,c.first_name,c.last_name
order by revenue desc
limit 3;


/* 6. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */

select distinct c.email,c.first_name,c.last_name
from customer c 
join invoice on c.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id
	from track t 
	join genre as g on t.genre_id = g.genre_id
	where g.name = "Rock"
    )
order by email;


/* 7. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */


select 
	a.name,
    a.artist_id,
    count(a.artist_id) as no_of_songs
from track
join album on album.album_id = track.album_id
join artist a on a.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id 
where genre.name = 'Rock'
group by a.artist_id,a.name 
order by no_of_songs desc
limit 10;

/* 8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */ 


select name, milliseconds
from track
where milliseconds > ( 
	select avg(milliseconds) as avg_track_length
    from track)
order by milliseconds;


/* 9. write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount 
*/

with customer_with_country as ( 
	select  c.customer_id,c.first_name,c.last_name,
            i.billing_country,round(sum(i.total),2) as total_spending,
			row_number() over (partition by billing_country order by sum(total) desc) as row_no
    from invoice i
    join customer c on i.customer_id = c.customer_id
    group by 1,2,3,4
    order by 4 asc, 5 desc)
select customer_id,first_name,last_name,billing_country 
from customer_with_country 
where row_no = 1;

/* 10. We want to find out which is most popular genre for each country . Determine the most popular 
 genre by genre with highest amount of purchase
*/
    with popular_genre as (
		select count(il.invoice_id) as purchases, c.country, g.name, g.genre_id,
				row_number() over (partition by c.country order by count(il.invoice_id) desc) as row_no
		from invoice_line il
		join invoice i on il.invoice_id = i.invoice_id
		join customer c on c.customer_id = i.customer_id
		join track on track.track_id = il.track_id
		join genre g on track.genre_id = g.genre_id
		group by 2,3,4
		order by 2 asc, 1 desc
)
select purchases,country,name from popular_genre 
where row_no = 1
order by purchases desc;
