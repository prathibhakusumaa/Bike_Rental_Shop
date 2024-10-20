/* Emily would like to know how many bikes the shop owns by category. Can you get this for her? 
Display the category name and the number of bikes the shop owns in each category (call this column number_of_bikes ). Show only the categories
where the number of bikes is greater than 2 .*/

select category, count(distinct(id)) as number_of_bikes
from bike
group by category 
having count(distinct(id)) >2;

-------------------------------------------------------------
/*. Emily needs a list of customer names with the total number of memberships purchased by each.
For each customer, display the customer's name and the count of memberships purchased (call this column membership_count ). Sort the
results by membership_count , starting with the customer who has purchased the highest number of memberships.
Keep in mind that some customers may not have purchased any memberships yet. In such a situation, display 0 for the membership_count .*/

select name, count(distinct(membership_type_id)) as membership_count
from customer c
left join membership m on c.id = m.customer_id
group by name
order by membership_count desc

--------------------------------------------------------------
/*Emily is working on a special offer for the winter months. Can you help her prepare a list of new rental prices?
For each bike, display its ID, category, old price per hour (call this column old_price_per_hour ), discounted price per hour (call it new_price_per_hour ), old
price per day (call it old_price_per_day ), and discounted price per day (call it new_price_per_day ).
Electric bikes should have a 10% discount for hourly rentals and a 20% discount for daily rentals. Mountain bikes should have a 20% discount for
hourly rentals and a 50% discount for daily rentals. All other bikes should have a 50% discount for all types of rentals.
Round the new prices to 2 decimal digits.*/

select id,category, price_per_hour as old_price_per_hour, price_per_day as old_price_per_day,
	case
		when category = 'electric' then round(price_per_hour * 0.9,2)
		when category = 'mountain bike' then round(price_per_hour * 0.8,2)
	else round(price_per_hour * 0.5,2)
	end as new_price_per_hour,
	case  
		when category = 'electric' then round(price_per_day *0.8,2)
	else round(price_per_day * 0.5,2)
	end as new_price_per_day
from bike

------------------------------------------------------------
/* Emily is looking for counts of the rented bikes and of the available bikes in each category.
Display the number of available bikes (call this column available_bikes_count ) and the number of rented bikes (call this column 
rented_bikes_count ) by bike category.*/ 

select category, count(distinct(available_bike_id)) as available_bike_id, count(distinct(rented_bike_id)) as rented_bike_count
from(select category,
	 case
	 	when status = 'available' then id
	 end as available_bike_id,
	 case
	 	when status = 'rented' then id
	 end as rented_bike_id
	from bike)
group by category

-------------------------------------------------------------
/* . Emily is preparing a sales report. She needs to know the total revenue from rentals by month, the total by year, and the all-time across all the
years. 
Display the total revenue from rentals for each month, the total for each year, and the total across all the years. Do not take memberships into
account. There should be 3 columns: year , month , and revenue . Sort the results chronologically. Display the year total after all the month
totals for the corresponding year. Show the all-time total as the last row*/

select extract(year from start_timestamp) as year,extract (month from start_timestamp) as month, sum(total_paid) as revenue
from rental
group by year, month
union
select extract(year from start_timestamp) as year,null as month, sum(total_paid) as revenue
from rental
group by year
union
select null as year, null as month, sum(total_paid) as revenue
from rental
order by year, month

-------------------------------------------------------------
/*Emily has asked you to get the total revenue from memberships for each combination of year, month, and membership type.
Display the year, the month, the name of the membership type (call this column membership_type_name ), and the total revenue (call this column 
total_revenue ) for every combination of year, month, and membership type. Sort the results by year, month, and name of membership type*/

with cte as (select extract(year from start_date) as year, extract (month from start_date) as month, 
name as membership_type_name, total_paid as total_revenue
from membership m
left join membership_type p on m.membership_type_id = p.id)
select year, month, membership_type_name, sum(total_revenue) as total_revenue
from cte
group by year, month, membership_type_name
union
select year, null as month, membership_type_name, sum(total_revenue) as total_revenue
from cte
group by year, membership_type_name
union
select null as year, null as month, membership_type_name, sum(total_revenue) as total_revenue
from cte
group by month, membership_type_name
order by year, month, membership_type_name
																	 
---------------------------------------------------------------------------
/* Next, Emily would like data about memberships purchased in 2023, with subtotals and grand totals for all the different combinations of membership
types and months. Display the total revenue from memberships purchased in 2023 for each combination of month and membership type. Generate subtotals and
grand totals for all possible combinations. There should be 3 columns: membership_type_name , month , and total_revenue. 
Sort the results by membership type name alphabetically and then chronologically by month*/

with cte as (select name as membership_type_name, extract(month from start_date) as month, total_paid as revenue
from membership_type t
right join membership m on t.id = m.membership_type_id)

select membership_type_name, month, sum(revenue) as revenue
from cte
group by membership_type_name, month
union
select membership_type_name, null as month, sum(revenue) as revenue
from cte
group by membership_type_name
union
select null as membership_type_name, month, sum(revenue) as revenue
from cte
group by month
order by membership_type_name asc, month asc

------------------------------------------------------------
/* Emily wants to segment customers based on the number of rentals and see the count of customers in each segment. Use your SQL skills to get
this!  Categorize customers based on their rental history as follows:
Customers who have had more than 10 rentals are categorized as 'more than 10' .
Customers who have had 5 to 10 rentals (inclusive) are categorized as 'between 5 and 10' .
Customers who have had fewer than 5 rentals should be categorized as 'fewer than 5' .
Calculate the number of customers in each category. Display two columns: rental_count_category (the rental count category) and customer_count (the
number of customers in each category).*/ 
select rental_count_category,  count(distinct(customer_id))as customer_count
from (
select customer_id,
	case 
		when count(distinct(id)) > 10 then 'more than 10'
		when count(distinct(id)) <=10 and count(distinct(id)) <= 5 then 'between 5 and 10'
		else 'fewer than 5'
	end as rental_count_category 
from rental
group by customer_id) 
group by rental_count_category