Create Database WalmartSales;

CREATE TABLE sales(
	invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);


-- Adding addtional columns for time and period related context -----

-- time_of_day

SELECT 
	time,
    (CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:00:01" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"	
	END ) AS time_of_day
FROM walmartsales.sales;

alter table walmartsales.sales Add column time_of_day varchar(30);

update walmartsales.sales 
set time_of_day = (	
	CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:00:01" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"	
	END 
    );

-- day_name --------

alter table walmartsales.sales add column day_name varchar(25);
update walmartsales.sales 
	set day_name = dayname(date); 
    
-- month_name 

alter table walmartsales.sales add column month_name varchar(30);
update walmartsales.sales
	set month_name = monthname(date);
    
	-- -------------------------------------------------------------------------

    --  EDA 
    
    -- --------------------------------------------------------------------------

-- 1. How many unique cities does the data have? 
 
 Select distinct(city)
 from walmartsales.sales;
 
 -- 2. In which city is each branch?
 
 select 
	distinct(city),
    branch
from walmartsales.sales;

-- ---------------------------------------------------------------------
-- PRODUCT ANALYSIS ---------------------------------------------

-- How many unique product lines does the data have? 

 SELECT 
    ROW_NUMBER() OVER () AS serial_number,
    product_line
FROM 
    (SELECT DISTINCT product_line FROM walmartsales.sales) AS subquery;
    
-- What is the most common payment method ? 

Select 
	payment,
    count(payment) as used_count
from walmartsales.sales
group by payment
order by used_count desc;

-- What is the most selling product line?

select 
	product_line,
    sum(total) as sales_amt
from walmartsales.sales
group by product_line
order By sales_amt desc
limit 3;

-- What is the total revenue by month?

select 
	month_name as month,
	sum(total) as sales_amt
from walmartsales.sales
group by month
order by sales_amt desc;

-- What month had the largest COGS?

select 
	month_name as month,
	sum(cogs) as total_cogs
from walmartsales.sales
group by month
order by total_cogs desc;

-- What is the city with the largest revenue?

select 
	branch,
	city,
	sum(total) as total_revenue
from walmartsales.sales
group by city,branch
order by total_revenue desc;

-- What product line had the largest tax applied ? 

select 
	product_line,
	round(avg(tax_pct),2) as avg_tax_pct
from walmartsales.sales
group by product_line
order by avg_tax_pct desc;

-- Which branch sold more products than average product sold?

select 
	branch, 
    sum(quantity) as qty
from walmartsales.sales
group by branch
having qty > (select avg(quantity) from walmartsales.sales)
order by qty desc;

-- what is most common product line by gender 

select 
	gender,
    product_line,
    count(gender) as total_order
from walmartsales.sales
group by product_line,gender
order by total_order desc;

-- What is the average rating of each product line?

select 
	product_line,
    round(avg(rating),2) as avg_rating
from walmartsales.sales
group by product_line
order by avg_rating desc;

-- ---------------------------------------------------------------------
-- SALES ANALYSIS -----------------------------------------------------

-- Number of sales made in each time of the day per weekday

SELECT 
	time_of_day,
    count(*) as total_sales_order
FROM walmartsales.sales
WHERE day_name = 'Monday'
GROUP BY time_of_day
ORDER BY total_sales_order desc;

-- Which of the customer type brings the most revenue ? -------------------------------

Select 
	customer_type,
    round(sum(total),2) as revenue
From walmartsales.sales
group by customer_type
order by revenue desc;

--  which city has largest tax percentage ?

select 
	city,
	round(avg(tax_pct),2) as vat
from walmartsales.sales
group by city
order by vat desc;

-- -----------------------------------------------------------------------
--  CUSTOMER INFROMATION -------------------------------------------------

SELECT 
	distinct customer_type,
    count(*) as no_of_Customer
FROM walmartsales.sales
GROUP BY customer_type;


--  unique payment methods are there ?
SELECT 
	payment,
    count(*) as no_of_Customer
FROM walmartsales.sales
GROUP BY payment;

--  gender distrubution of customer

SELECT 
	gender,
    customer_type,
    count(*) as no_of_Customer
FROM walmartsales.sales
GROUP BY gender,customer_type;

-- rating by customer 

select 
	round(avg(rating),2) as avg_rating 
from walmartsales.sales;
 
-- rating by time_of_day 
	
select
	time_of_day,
	round(avg(rating),2) as avg_rating 
from walmartsales.sales
group by time_of_day
order by avg_rating desc;

-- rating by branch 

select
	branch,
	round(avg(rating),2) as avg_rating 
from walmartsales.sales
group by branch
order by avg_rating desc;

-- rating by day 

select
	day_name,
	round(avg(rating),2) as avg_rating 
from walmartsales.sales
group by day_name
order by avg_rating desc;














