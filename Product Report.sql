--- Product Report
--- total units sold
--- net units sold ( total units sold - returned units)
--- Cost Of Goods Sold
--- Gross Revenue (quantity * list price)
--- Net Revenue ( net units sold * list price -discounts)
--- Gross margin(Profit) (net revenue - cost of goods sold)
--- Gross margin pct
--- Return Rate
--- Avg.Selling price
-- Total Discount
--- lifespan ( months it has been listed for sale)
--- products revenue % contribution to total revenue
Go
create or alter view product_report as 
with base_query as(
--- selecting the necessary columns 
select 
p.product_id,p.category,p.supplier,p.season,p.cost_price,p.list_price,
t.date,t.quantity,t.discount,t.returned,t.transaction_id,t.customer_id,
s.store_name,s.region
from dbo.product_data p
inner join dbo.sales_data t
on p.product_id = t.product_id
inner join dbo.store_data s
on s.store_id = t.store_id
),
product_aggregations as 
(
--- calculating the required columns
select product_id,category,supplier,season,region,store_name,
count(distinct customer_id) as total_customers,
sum(quantity) as total_units_sold,
sum(quantity-coalesce(returned,0)) as net_quantity_sold,
sum(quantity * list_price) as gross_revenue,
sum((quantity -coalesce(returned,0)) * cost_price) as Cost_Of_Goods_Sold,
round(sum((quantity -coalesce(returned,0)) *list_price *(1-discount/100.0)),2) as net_revenue,
sum((quantity -coalesce(returned,0)) *list_price *(1-discount/100.0)) - 
sum((quantity -coalesce(returned,0)) * cost_price) as profit,
round(SUM(COALESCE(returned, 0)) * 100.0 / NULLIF(SUM(quantity), 0),2) as return_rate,
count(distinct transaction_id) as total_transactions,
SUM(discount) as total_discount_received,
round(sum((quantity -coalesce(returned,0)) *list_price *(1-discount/100.0)) /
nullif(sum(quantity-coalesce(returned,0)),0),2) as avg_selling_price,
max(date) as last_sale_date,
datediff(month,min(date),max(date)) as lifespan_months
from base_query
group by product_id,category,supplier,season,region,store_name
)
select *
from product_aggregations
Go
