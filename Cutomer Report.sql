--- customer report
--- 1. Base query for customer report with key metrics and dimensions
--- 2. Segment customers into categories based on their purchasing behavior,age group and repeating customers
--- 3.customer level metrics:
--- net quantity purchased(total quantity sold - total quantity returned)
--- total transactions
--- total discount received
--- total revenue generated
--- last transaction date
--- lifespan in months since first purchase
--- recency
--- average transaction  value(ATV)
Go
create or alter view dbo.customer_report as 
with base_query as (
--- Base query
select
t.customer_id,c.age,t.date,t.quantity,t.discount,t.returned,p.list_price
,t.transaction_id
from dbo.customer_data c
left join  dbo.sales_data t
on c.customer_id = t.customer_id
left join dbo.product_data p
on p.product_id = t.product_id
left join dbo.store_data s
on s.store_id = t.store_id
 where t.customer_id is not null
 ), --- time_metrics CTE to calculate customer lifespan,recency and last transaction date
time_metrics as (

select customer_id,max(date) as last_transaction_date,
datediff(month,min(date),max(date)) as lifespan_months,
datediff(month,max(date),getdate()) as recency_months
from base_query
group by customer_id
),
customer_segmentation as (--- Segment customers based on purchasing behavior and age groups

 select customer_id,age,
 --- Segment customers based on purchasing behavior
 case when count(distinct transaction_id)=1 then 'One-Time-Customer'
             when count(distinct transaction_id)>1 then 'Repeating-Customer'
             else 'Unknown'
             end as customer_frequency,
 --- Segment customers based on age groups
 case when age < 30 then 'Youth'
      when age between 30 and 45 then 'Adults'
      When age between 45 and 60  then 'Old'
      when age >60 then 'Seniors'
      else 'Unknown'
      end as age_range
from base_query
group by customer_id,age
),
customer_aggregations as (--- customer metrics aggregations

select
customer_id,
sum(quantity-coalesce(returned,0)) as net_quantity_purchased,
count(distinct transaction_id) as total_transactions,
sum(discount) as total_discount_received,
round(sum((quantity-coalesce(returned,0)) * (list_price * (1 - discount / 100.0))),2) as total_revenue_generated,
round(sum((quantity-coalesce(returned,0)) * (list_price * (1 - discount / 100.0))) /
nullif(count(distinct transaction_id),0),2)  as average_transaction_value,
SUM(COALESCE(returned, 0)) * 100.0 / NULLIF(SUM(quantity), 0) AS return_rate_pct
from base_query
group by customer_id 
)
select 
ca.customer_id,ca.total_transactions,cs.customer_frequency,cs.age,cs.age_range
,tm.last_transaction_date,tm.lifespan_months,tm.recency_months,ca.net_quantity_purchased,ca.return_rate_pct,
ca.total_discount_received,ca.total_revenue_generated,
case when ca.total_revenue_generated < 500 then 'Regular Customer'
    when ca.total_revenue_generated > 500 then 'VIP Customer'
    else 'Unknown'
End as Customer_spend
,ca.average_transaction_value 
from customer_aggregations ca
left join customer_segmentation cs
on ca.customer_id = cs.customer_id
left join time_metrics tm
on ca.customer_id = tm.customer_id
GO



