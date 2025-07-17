create database super_store 

use super_store

create table sales_store (transaction_id varchar(15),customer_id varchar(15),customer_name varchar(40),
customer_age int,gender varchar(10), product_id varchar(15),product_name
 varchar (40),product_category varchar(40),
quantiy int, prce float, payment_mode varchar(30),purchase_date date, time_of_purchase time,status varchar(10))
 
 select * from sales_store

 drop table sales_store

 set dateformat dmy
 bulk insert sales_store 
 from 'C:\Users\saket\Downloads\sales_store_updated_allign_with_video.csv'
 with (firstrow=2,fieldterminator=',',rowterminator='\n')

 select * from sales_store

 select * into sales
 from sales_store

 select * from sales

 --Data cleaning part step1 to check for Duplicates

 select transaction_id, count(*)
 from sales
 group by transaction_id
 having count(transaction_id)>1

/*TXN240646
TXN342128
TXN855235
TXN981773*/

--we use windows function row_number--

with CTE as (
select *, row_number() over(partition by transaction_id order by transaction_id) Row_Number from sales)

--delete from CTE
--where row_number=2

select * from CTE
where transaction_id in ('TXN240646','TXN342128','TXN855235','TXN981773')

select *from sales

--step 2 rename the columns

sp_rename 'sales.quantiy','quantity'

sp_rename 'sales.prce','price'

select * from sales

--step3 check for data types

select column_name,DATA_TYPE from INFORMATION_SCHEMA.columns
where table_name='sales'

--step 4 check for null values

select * from sales
where customer_id is null

select count(*) as Total_null_rows,
sum(case when transaction_id is null then 1 else 0 end) from sales

DECLARE @TableName NVARCHAR(MAX) = 'sales';  -- Replace with your table
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, COUNT(*) AS NullCount
     FROM ' + QUOTENAME('sales') + ' 
     WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL', 
    ' UNION ALL '
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Sales' 
  AND TABLE_SCHEMA = 'dbo';  -- Change if your table is under another schema

EXEC sp_executesql @SQL;

select count(*) from sales
where customer_id is null

--Treating null values

select * from sales
where transaction_id is null
or
customer_id is null
or 
customer_name is null
or
customer_age is null
or 
gender is null
or
product_id is null
or
product_name is null
or
product_category is null
or
quantity is null
or
price is null
or
payment_mode is null
or
purchase_date is null
or
time_of_purchase is null
or 
status is null

--deleting the outlier row

delete from sales
where transaction_id is null

select * from sales
where customer_name ='Ehsaan Ram'

update sales set customer_id='CUST9494'
where customer_name ='Ehsaan Ram'

select * from sales
where customer_name ='Damini Raju'

update sales set customer_id='CUST1401'
where transaction_id ='TXN985663'

select * from sales 
where customer_id='CUST1003'

update sales set customer_name='Mahika Saini',customer_age=35,gender='Male'
where transaction_id='TXN432798'

select * from sales

select distinct gender from sales


update sales set gender='M' where gender='Male'


select distinct payment_mode from sales

update sales set payment_mode ='CC'
where payment_mode='Credit Card'

--Data Analysis

--what are the top 5 most selling products by quantity?

select top 5 product_name, sum(quantity) Total_Quantity from sales 
where status='delivered'
group by product_name 
order by 2 desc

select distinct status from sales

--which products are most frequently cancelled?

select Top 5 product_name, count(*) count_of_cancellation from sales
where status='cancelled'
group by product_name
order by 2 desc

--what time of the day  has the highest no of purchases ?

select * from sales

select 
		case 
				when datepart(hour, time_of_purchase) between 0 and 5 then 'Night'
				when datepart(hour, time_of_purchase) between 6 and 11 then 'Morning'
				when datepart(hour, time_of_purchase) between 12 and 17 then 'Afternoon'
				when datepart(hour, time_of_purchase) between 18 and 23 then 'Evening'
				end as 'time_of_day', count(*) as Total_orders from sales
group by 
				case 
				when datepart(hour, time_of_purchase) between 0 and 5 then 'Night'
				when datepart(hour, time_of_purchase) between 6 and 11 then 'Morning'
				when datepart(hour, time_of_purchase) between 12 and 17 then 'Afternoon'
				when datepart(hour, time_of_purchase) between 18 and 23 then 'Evening'
				end 
order by 2 desc


--who are the top 5 highest spending customer

select * from sales

select Top 5  customer_name , format(sum(price*quantity),'C0','en-IN') as Total_price from sales
group by customer_name
order by sum(price*quantity) desc

--which product category generates the highest revenue?

select distinct product_category from sales

select * from sales

select Top 1 product_category, format(sum( price*quantity),'C0','en-IN') as Total_Revenue from sales
group by product_category
order by  sum( price*quantity) desc

--what is the return/cancellation rate per category

select * from sales

select product_category, format(count(case when status='cancelled' then 1 end)*100.0/count(*),'N2')+'%' as cancelled_percent from sales
group by product_category
order by 2 desc


select product_category, format(count(case when status='returned' then 1 end)*100.0/count(*) ,'N2')+'%' as returned_percent from sales
group by product_category
order by 2 desc

--what is the most preferable payment mode

select * from sales

select payment_mode , count(*) Count from sales
group by payment_mode
order by 2 desc

--How does age group affect purchasing behaviour

select * from sales

select min( customer_age), max(customer_age) from sales

select 
		case 
				when customer_age between 18 and 25 then '18-25'
				when customer_age between 26 and 35 then '26-35'
				when customer_age between 36 and 45 then '36-45'
				when customer_age between 46 and 60 then '46-60'
				end as 'Age_Group' ,format(sum(quantity*price),'C0','en-IN') as Total_sales from sales
group by 
				case 
				when customer_age between 18 and 25 then '18-25'
				when customer_age between 26 and 35 then '26-35'
				when customer_age between 36 and 45 then '36-45'
				when customer_age between 46 and 60 then '46-60'
				end
order by sum(quantity*price) desc


--whats the monthly sales trend

select * from sales

select datename(month,purchase_date) Month , format(sum(quantity*price),'C0','en-IN') as Total_sales from sales
group by datename(month,purchase_date)
order by sum(quantity*price) desc

--Are certain Genders purchasing more specific product categories

select * from sales

select gender, product_category, count(*) count_of_product_category from Sales
group by gender, product_category
order by gender

--Method 2 

select * from (select Gender, Product_category from sales) as main_table
pivot(count(gender) for gender in ([Female],[Male])) as pvt_table
order by product_category






















