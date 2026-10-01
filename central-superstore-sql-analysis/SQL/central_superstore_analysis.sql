/* Database Selection */

use centralsuperstoredw;
go


/* Source Exploration */

select top 10 *
from central_superstore;

select count(*) as total_records
from central_superstore;

select
column_name,
data_type,
character_maximum_length
from information_schema.columns
where table_name = 'central_superstore';

select
row_id,
count(*) as number_of_rows
from central_superstore
group by row_id
having count(*) > 1;

select
order_id,
count(*) as number_of_rows
from central_superstore
group by order_id
having count(*) > 1;

select
customer_id,
count(*) as number_of_rows
from central_superstore
group by customer_id
having count(*) > 1;

select
product_id,
count(*) as number_of_rows
from central_superstore
group by product_id
having count(*) > 1;


/* Data Distribution */

select
category,
count(*) as number_of_rows,
sum(sales) as total_sales
from central_superstore
group by category
order by total_sales desc;

select
sub_category,
count(*) as number_of_rows,
sum(sales) as total_sales
from central_superstore
group by sub_category
order by total_sales desc;

select
region,
count(*) as number_of_rows,
sum(sales) as total_sales
from central_superstore
group by region
order by total_sales desc;

select
segment,
count(*) as number_of_rows,
sum(sales) as total_sales
from central_superstore
group by segment
order by total_sales desc;

select
ship_mode,
count(*) as number_of_rows,
sum(sales) as total_sales
from central_superstore
group by ship_mode
order by total_sales desc;


/* Data Quality */

select
sum(case when row_id is null then 1 else 0 end) as missing_row_id,
sum(case when order_id is null or trim(order_id) = '' then 1 else 0 end) as missing_order_id,
sum(case when order_date is null then 1 else 0 end) as missing_order_date,
sum(case when ship_date is null then 1 else 0 end) as missing_ship_date,
sum(case when ship_mode is null or trim(ship_mode) = '' then 1 else 0 end) as missing_ship_mode,
sum(case when customer_id is null or trim(customer_id) = '' then 1 else 0 end) as missing_customer_id,
sum(case when customer_name is null or trim(customer_name) = '' then 1 else 0 end) as missing_customer_name,
sum(case when segment is null or trim(segment) = '' then 1 else 0 end) as missing_segment,
sum(case when country is null or trim(country) = '' then 1 else 0 end) as missing_country,
sum(case when city is null or trim(city) = '' then 1 else 0 end) as missing_city,
sum(case when state is null or trim(state) = '' then 1 else 0 end) as missing_state,
sum(case when postal_code is null then 1 else 0 end) as missing_postal_code,
sum(case when region is null or trim(region) = '' then 1 else 0 end) as missing_region,
sum(case when product_id is null or trim(product_id) = '' then 1 else 0 end) as missing_product_id,
sum(case when category is null or trim(category) = '' then 1 else 0 end) as missing_category,
sum(case when sub_category is null or trim(sub_category) = '' then 1 else 0 end) as missing_sub_category,
sum(case when product_name is null or trim(product_name) = '' then 1 else 0 end) as missing_product_name,
sum(case when sales is null then 1 else 0 end) as missing_sales,
sum(case when quantity is null then 1 else 0 end) as missing_quantity,
sum(case when discount is null then 1 else 0 end) as missing_discount,
sum(case when profit is null then 1 else 0 end) as missing_profit
from central_superstore;


/* Build Star Schema */

drop table if exists fact_sales;
drop table if exists dim_customer;
drop table if exists dim_product;
drop table if exists dim_location;
drop table if exists dim_ship_mode;
drop table if exists dim_date;

create table dim_customer (
customer_key int identity(1,1) primary key,
customer_id varchar(50) not null unique,
customer_name varchar(200),
segment varchar(50)
);

create table dim_product (
product_key int identity(1,1) primary key,
product_id varchar(50) not null unique,
product_name varchar(300),
category varchar(100),
sub_category varchar(100)
);

create table dim_location (
location_key int identity(1,1) primary key,
country varchar(100),
city varchar(100),
state varchar(100),
postal_code int,
region varchar(100),
constraint uq_location unique (country, city, state, postal_code, region)
);

create table dim_ship_mode (
ship_mode_key int identity(1,1) primary key,
ship_mode varchar(100) not null unique
);

create table dim_date (
date_key int primary key,
full_date date not null unique,
year int,
quarter int,
month int,
month_name varchar(20),
day int,
day_name varchar(20)
);


/* Load Dimension Data */

insert into dim_customer (customer_id, customer_name, segment)
select distinct
customer_id,
customer_name,
segment
from central_superstore
where customer_id is not null;

insert into dim_product (product_id, product_name, category, sub_category)
select
product_id,
max(product_name),
max(category),
max(sub_category)
from central_superstore
where product_id is not null
group by product_id;

insert into dim_location (country, city, state, postal_code, region)
select distinct
country,
city,
state,
postal_code,
region
from central_superstore;

insert into dim_ship_mode (ship_mode)
select distinct
ship_mode
from central_superstore
where ship_mode is not null;

insert into dim_date (
date_key,
full_date,
year,
quarter,
month,
month_name,
day,
day_name
)
select distinct
cast(convert(varchar(8), full_date, 112) as int),
full_date,
year(full_date),
datepart(quarter, full_date),
month(full_date),
datename(month, full_date),
day(full_date),
datename(weekday, full_date)
from (
select order_date as full_date
from central_superstore

union

select ship_date as full_date
from central_superstore
) as dates
where full_date is not null;


/* Build Fact Table */

create table fact_sales (
fact_key int identity(1,1) primary key,
row_id int not null,
order_id varchar(50),
customer_key int not null,
product_key int not null,
location_key int not null,
ship_mode_key int not null,
order_date_key int not null,
ship_date_key int not null,
sales decimal(12,4),
quantity int,
discount decimal(8,4),
profit decimal(12,4),
shipping_duration int,
foreign key (customer_key) references dim_customer(customer_key),
foreign key (product_key) references dim_product(product_key),
foreign key (location_key) references dim_location(location_key),
foreign key (ship_mode_key) references dim_ship_mode(ship_mode_key),
foreign key (order_date_key) references dim_date(date_key),
foreign key (ship_date_key) references dim_date(date_key)
);

insert into fact_sales (
row_id,
order_id,
customer_key,
product_key,
location_key,
ship_mode_key,
order_date_key,
ship_date_key,
sales,
quantity,
discount,
profit,
shipping_duration
)
select
r.row_id,
r.order_id,
c.customer_key,
p.product_key,
l.location_key,
sm.ship_mode_key,
od.date_key,
sd.date_key,
r.sales,
r.quantity,
r.discount,
r.profit,
datediff(day, r.order_date, r.ship_date)
from central_superstore r
inner join dim_customer c
on r.customer_id = c.customer_id
inner join dim_product p
on r.product_id = p.product_id
inner join dim_location l
on r.country = l.country
and r.city = l.city
and r.state = l.state
and r.postal_code = l.postal_code
and r.region = l.region
inner join dim_ship_mode sm
on r.ship_mode = sm.ship_mode
inner join dim_date od
on r.order_date = od.full_date
inner join dim_date sd
on r.ship_date = sd.full_date;


/* Warehouse Verification */

select
'central_superstore table' as table_name,
count(*) as number_of_rows
from central_superstore

union all

select 'dim_customer', count(*)
from dim_customer

union all

select 'dim_product', count(*)
from dim_product

union all

select 'dim_location', count(*)
from dim_location

union all

select 'dim_ship_mode', count(*)
from dim_ship_mode

union all

select 'dim_date', count(*)
from dim_date

union all

select 'fact_sales', count(*)
from fact_sales;

select top 20 *
from fact_sales;


/* Business Analytics */

select round(sum(sales), 2) as total_sales
from fact_sales;

select round(sum(profit), 2) as total_profit
from fact_sales;

select sum(quantity) as total_quantity
from fact_sales;

select count(distinct order_id) as total_orders
from fact_sales;

select count(distinct customer_key) as total_customers
from fact_sales;

select
round(sum(sales) / count(distinct order_id), 2) as average_order_value
from fact_sales;

select
round(avg(cast(shipping_duration as decimal(10,2))), 2) as average_shipping_duration
from fact_sales;

select
round((sum(profit) / sum(sales)) * 100, 2) as profit_margin_percentage
from fact_sales;

select
p.category,
round(sum(f.sales), 2) as total_sales,
round(sum(f.profit), 2) as total_profit,
round((sum(f.profit) / sum(f.sales)) * 100, 2) as profit_margin
from fact_sales f
inner join dim_product p
on f.product_key = p.product_key
group by p.category
order by total_sales desc;

select
p.sub_category,
round(sum(f.sales), 2) as total_sales,
round(sum(f.profit), 2) as total_profit
from fact_sales f
inner join dim_product p
on f.product_key = p.product_key
group by p.sub_category
order by total_sales desc;

select
l.region,
round(sum(f.sales), 2) as total_sales,
round(sum(f.profit), 2) as total_profit
from fact_sales f
inner join dim_location l
on f.location_key = l.location_key
group by l.region
order by total_sales desc;

select
c.segment,
round(sum(f.sales), 2) as total_sales,
round(sum(f.profit), 2) as total_profit
from fact_sales f
inner join dim_customer c
on f.customer_key = c.customer_key
group by c.segment
order by total_sales desc;

select
sm.ship_mode,
round(sum(f.sales), 2) as total_sales,
round(sum(f.profit), 2) as total_profit,
round(avg(cast(f.shipping_duration as decimal(10,2))), 2) as average_shipping_duration
from fact_sales f
inner join dim_ship_mode sm
on f.ship_mode_key = sm.ship_mode_key
group by sm.ship_mode
order by total_sales desc;

select
d.year,
round(sum(f.sales), 2) as total_sales,
round(sum(f.profit), 2) as total_profit
from fact_sales f
inner join dim_date d
on f.order_date_key = d.date_key
group by d.year
order by d.year;

select
d.year,
d.month,
d.month_name,
round(sum(f.sales), 2) as total_sales,
round(sum(f.profit), 2) as total_profit
from fact_sales f
inner join dim_date d
on f.order_date_key = d.date_key
group by d.year, d.month, d.month_name
order by d.year, d.month;

select top 10
c.customer_id,
c.customer_name,
round(sum(f.sales), 2) as total_sales,
round(sum(f.profit), 2) as total_profit
from fact_sales f
inner join dim_customer c
on f.customer_key = c.customer_key
group by c.customer_id, c.customer_name
order by total_sales desc;

select top 10
p.product_id,
p.product_name,
p.category,
round(sum(f.sales), 2) as total_sales,
round(sum(f.profit), 2) as total_profit
from fact_sales f
inner join dim_product p
on f.product_key = p.product_key
group by p.product_id, p.product_name, p.category
order by total_sales desc;

select
p.product_id,
p.product_name,
p.category,
round(sum(f.sales), 2) as total_sales,
round(sum(f.profit), 2) as total_profit
from fact_sales f
inner join dim_product p
on f.product_key = p.product_key
group by p.product_id, p.product_name, p.category
having sum(f.profit) < 0
order by total_profit asc;

select top 10
p.product_name,
round(sum(f.profit), 2) as total_profit
from fact_sales f
inner join dim_product p
on f.product_key = p.product_key
group by p.product_name
order by total_profit desc;


/* Advanced Analytics */

with product_sales as (
select
p.product_id,
p.product_name,
sum(f.sales) as total_sales
from fact_sales f
inner join dim_product p
on f.product_key = p.product_key
group by p.product_id, p.product_name
)
select top 10 *
from product_sales
order by total_sales desc;

with product_sales as (
select
p.product_name,
sum(f.sales) as total_sales
from fact_sales f
inner join dim_product p
on f.product_key = p.product_key
group by p.product_name
)
select
product_name,
round(total_sales, 2) as total_sales,
rank() over (order by total_sales desc) as sales_rank
from product_sales
order by sales_rank;

with category_sales as (
select
p.category,
sum(f.sales) as total_sales
from fact_sales f
inner join dim_product p
on f.product_key = p.product_key
group by p.category
)
select
category,
round(total_sales, 2) as total_sales,
round(total_sales / sum(total_sales) over () * 100, 2) as sales_percentage
from category_sales
order by total_sales desc;

with yearly_sales as (
select
d.year,
sum(f.sales) as total_sales
from fact_sales f
inner join dim_date d
on f.order_date_key = d.date_key
group by d.year
)
select
year,
round(total_sales, 2) as total_sales,
round(
(total_sales - lag(total_sales) over (order by year))
/ lag(total_sales) over (order by year) * 100,
2
) as growth_percentage
from yearly_sales
order by year;


/* Final Star Schema */

select
f.fact_key,
f.order_id,
c.customer_id,
c.customer_name,
c.segment,
p.product_id,
p.product_name,
p.category,
p.sub_category,
l.country,
l.city,
l.state,
l.postal_code,
l.region,
sm.ship_mode,
od.full_date as order_date,
sd.full_date as ship_date,
f.shipping_duration,
f.sales,
f.quantity,
f.discount,
f.profit
from fact_sales f
inner join dim_customer c
on f.customer_key = c.customer_key
inner join dim_product p
on f.product_key = p.product_key
inner join dim_location l
on f.location_key = l.location_key
inner join dim_ship_mode sm
on f.ship_mode_key = sm.ship_mode_key
inner join dim_date od
on f.order_date_key = od.date_key
inner join dim_date sd
on f.ship_date_key = sd.date_key;