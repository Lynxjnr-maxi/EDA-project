select* from dbo.customer_data
select * from dbo.product_data
select * from dbo.sales_data
select * from dbo.store_data
-- Database Exploration

select * from INFORMATION_SCHEMA.tables;
--- Dimensions Exploration
-- customer_data (problems: '???' in gender column)
select * from dbo.customer_data

select avg (age) as avg_age,min(age) as youngest_customer,max(age) as oldest_customer 
from dbo.customer_data

select distinct gender from dbo.customer_data
-- replace '???' with NULL in table
update dbo.customer_data
set gender= gender = NULL
where gender='???'

select distinct city from dbo.customer_data

select distinct email from dbo.customer_data
--- no duplicates
select customer_id,age,gender,city,email,count(*)as duplicates
from dbo.customer_data
group by customer_id,age,gender,city,email
having count(*)>1

---product_data

select * from dbo.product_data
--- change data type of product-id

alter table dbo.product_data
alter column product_id int
--- replace '???' with Null in category column 

update dbo.product_data
set category =replace(category,'???','NULL')
where category='???'

select distinct color from dbo.product_data
select distinct season from dbo.product_data
select distinct supplier from dbo.product_data

--- replace supplier
update dbo.product_data
set supplier=case supplier
             when 'suppliera' then 'A'
             when 'supplierb' then 'B'
             when 'supplierc' then 'C'
             when 'supplierd' then 'D'
             Else supplier
End

select * from dbo.product_data

--- change cost_price to round,2
alter table dbo.product_data
alter column cost_price decimal(5,2)

--- change list_price to round,2
alter table dbo.product_data
alter column list_price decimal(5,2)

--- NO duplicates
select product_id,category,color,size,season,supplier,cost_price,list_price,count(*)as duplicates
from dbo.product_data
group by product_id,category,color,size,season,supplier,cost_price,list_price
having count(*)>1

--- SALES_DATA
select* from dbo.sales_data

--- remove the 0's in transaction_id
UPDATE dbo.sales_data
SET transaction_id = 't' + REPLACE(SUBSTRING(transaction_id, 2, LEN(transaction_id)), '0', '')
WHERE transaction_id IS NOT NULL;

--- min,max date and lifespan
select min(date) as youngest_date ,max(date) as oldest_date,
datediff(month,min(date),max(date)) as lifespan
from dbo.sales_data

--- change data type of product_id,store_id
alter table dbo.sales_data
alter column product_id int

alter table dbo.sales_data
alter column store_id int

select distinct store_id from dbo.sales_data --- store_id '999' not accounted for in table store_data/data inconsistency

--- change discout data type
update dbo.sales_data
set discount= discount * 100
where discount is not null

alter table dbo.sales_data
alter column discount int

--- no duplicates
select transaction_id,date,product_id,store_id,quantity,discount,returned,COUNT(*) as duplicates
from dbo.sales_data
group by transaction_id,date,product_id,store_id,quantity,discount,returned
having count(*) >1

--- STORE_DATA
select * from dbo.store_data

-- change store_id data type to int
alter table dbo.store_data
alter column store_id int

--- correct the regions in region column from city to region(online source)
update dbo.store_data
set region= case region
           when 'Lisbon' then 'Lisbon Metropolitan Area'
           when 'Porto' then 'Northern Portugal'
           when 'Coimbra' then 'Central Portugal'
           else region
End
