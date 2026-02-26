SELECT * 
FROM myprojects.car_prices;

-- Sales in each state --

select
	state,
	COUNT(*)
from myprojects.car_prices
group by state;

select *
from myprojects.car_prices
where body = 'Navigation';

-- Make and Model --

select
make,
model,
count(*)
from myprojects.car_prices_valid
group by make,model
order by count(*) desc;

select *
from myprojects.car_prices_valid
where make='';

-- Avg State Prices --

drop table myprojects.car_prices_valid;

create temporary table myprojects.car_prices_valid as
select *
from myprojects.car_prices
where body != 'Navigation'
and make != '';

select
state,
avg(sellingprice) as avg_selling_price
from myprojects.car_prices_valid
group by state
order by avg_selling_price asc;

-- Avg Prices Per Month --

select saledate,
mid(saledate, 12, 4) as sale_year,
mid(saledate, 5, 3) as sale_month_name,
mid(saledate, 9, 2) as sale_day,
case mid(saledate, 5, 3)
	when 'Jan' then 1
	when 'Feb' then 2
	when 'Mar' then 3
	when 'Apr' then 4
	when 'May' then 5
	when 'Jun' then 6
	when 'Jul' then 7
	when 'Aug' then 8 
	when 'Sep' then 9 
	when 'Oct' then 10 
	when 'Nov' then 11
	when 'Dec' then 12
	else 'NONE'
end as sale_month
from myprojects.car_prices_valid
limit 1000;

drop table myprojects.car_prices_valid;

create temporary table myprojects.car_prices_valid as
select
`year` as manufactured_year,
make,
model,
trim,
body,
transmission,
vin,
state,
`condition` as manufactured_condition,
odometer,
color,
interior,
seller,
mmr,
sellingprice,
saledate,
mid(saledate, 12, 4) as sale_year,
mid(saledate, 5, 3) as sale_month_name,
mid(saledate, 9, 2) as sale_day,
cast(case mid(saledate, 5, 3)
	when 'Jan' then 1
	when 'Feb' then 2
	when 'Mar' then 3
	when 'Apr' then 4
	when 'May' then 5
	when 'Jun' then 6
	when 'Jul' then 7
	when 'Aug' then 8 
	when 'Sep' then 9 
	when 'Oct' then 10 
	when 'Nov' then 11
	when 'Dec' then 12
	else null
end as unsigned) as sale_month
from myprojects.car_prices
where body != 'Navigation'
and make !=''
and saledate != '';

-- # of Sales Each Month --

select 
sale_month,
count(*)
from myprojects.car_prices_valid
group by sale_month
order by sale_month asc;

select 
sale_month_name,
count(*)
from myprojects.car_prices_valid
group by sale_month_name;

select * 
from myprojects.car_prices_month
where sale_month_name = '';

-- Top Models Per Body Type --

select
make,
model,
body,
num_sales,
body_rank
from (
	select 
	make,
	model,
	body,
	count(*) as num_sales,
	rank() over(partition by body order by count(*) desc) as body_rank
	from myprojects.car_prices_valid
	group by make, model, body
) s
where body_rank <= 5
order by body asc, num_sales desc;

-- Sales Higher Than Model Average --

select
make,
model,
vin,
sale_year,
sale_month,
sale_day,
sellingprice,
avg_model,
sellingprice / avg_model as price_ratio
	from (
	select 
	make,
	model,
	vin,
	sale_year,
	sale_month,
	sale_day,
	sellingprice,
	avg(sellingprice) over(partition by make, model) as avg_model
    from myprojects.car_prices_valid
) s
where sellingprice > avg_model
order by sellingprice / avg_model desc;

-- Condtion and Sales Price --

select
case
	when car_conditon between 0 and 9 then '0-9'
    when car_conditon between 10 and 19 then '10-19'
    when car_conditon between 20 and 29 then '20-29'
    when car_conditon between 30 and 39 then '30-39'
    when car_conditon between 40 and 49 then '40-49'
end as car_condition_bucket,
count(*) as num_sales,
avg(sellingprice) as avg_selling_price
from myprojects.car_prices_valid
group by car_condition_bucket
order by car_condition_bucket;

-- odometer and Sales Price --

select
case 
	when odometer < 100000 then '0-99 999'
    when odometer < 200000 then '100 000-199 999'
    when odometer < 300000 then '20 000-299 999'
    when odometer < 400000 then '300 000-399 999'
    when odometer < 500000 then '400 000-499 999'
    when odometer < 600000 then '500 000-599 999'
    when odometer < 700000 then '600 000-699 999'
    when odometer < 800000 then '700 000-799 999'
    when odometer < 900000 then '800 000-899 999'
    when odometer < 1000000 then '900 000-999 999'
end as odometer_bucket,
count(*) as num_sales,
avg(sellingprice) as avg_selling_price
from myprojects.car_prices_valid
group by odometer_bucket
order by odometer_bucket asc;

-- Brand Details --

select 
make,
count(distinct model) as num_models,
count(*) as num_sales,
min(sellingprice) as min_price,
max(sellingprice) as max_price,
avg(sellingprice) as avg_price
from myprojects.car_prices_valid
group by make
order by avg_price desc;

-- Cars Sold Multiple Times --

select
manufactured_year,
make,
model,
trim,
body,
transmission,
vin,
state,
car_condition,
odometer,
color,
interior,
seller,
mmr,
sellingprice,
saledate,
sale_year,
sale_month,
sale_day,
count(*) over(partition by vin) as vin_sales
from myprojects.car_prices_valid
where count(*) over(partition by vin) > 1;





















