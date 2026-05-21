
 --- MEASURES EXPLORATION
 --- 1.Gross and Net Revenue,Gross Margin(profit) and Percentage Margin(how profitable),net quantity sold,markup
   with sales_kpis as (
  select distinct year(date) as year, sum(t.quantity) as total_quantity_sold,
        sum(coalesce(t.returned,0)) as total_quantity_returned,
       sum(t.quantity - coalesce(t.returned,0)) as net_quantity_sold,
       sum (p.list_price * t.quantity) as gross_revenue,
       sum((t.quantity- coalesce(t.returned,0)) * (p.list_price * (1-t.discount/100)))
       as net_revenue,  --- gross_revenue - discounts - returned products
       sum((t.quantity- coalesce(t.returned,0)) * p.cost_price) as Cost_Of_Goods_Sold
    from dbo.product_data p
          inner join dbo.sales_data t on
          p.product_id = t.product_id
    group by year(date)
  ),
  formatted_kpis as (
  select 
  gross_revenue,net_revenue,Cost_Of_Goods_Sold,net_quantity_sold,total_quantity_sold,total_quantity_returned,year,
        format(gross_revenue,'c','en-us') as gross_revenue_frmt,
        format(net_revenue,'c','en-us') as net_revenue_frmt,
        FORMAT(net_quantity_sold,'N0','en-us') as net_quantity_sold_frmt,
        format(total_quantity_sold,'N0','en-us') as total_quantity_sold_frmt,
        format(total_quantity_returned,'N0','en-us') as total_quantity_returned_frmt,
        format((total_quantity_returned* 1.0 /nullif( total_quantity_sold,0)),'P','en-us') as return_rate_frmt,
        (net_revenue - Cost_Of_Goods_Sold ) as gross_margin,
case when net_revenue > 0 
     then (net_revenue - Cost_Of_Goods_Sold) *1.00 / net_revenue
else 0
end as gross_margin_ratio,
case when net_revenue >0 
     then (net_revenue - Cost_Of_Goods_Sold) * 1.00 /Cost_Of_Goods_Sold
else 0
end as markup_ratio
from sales_kpis 
),
real_margins_kpis as (
select 
year,gross_revenue_frmt,net_revenue_frmt,net_quantity_sold_frmt,total_quantity_sold_frmt,total_quantity_returned_frmt,
return_rate_frmt,
FORMAT(gross_margin_ratio, 'P', 'en-US') AS gross_margin_percent,
FORMAT(gross_margin, 'C', 'en-US') AS gross_margin_frmt,
format(markup_ratio, 'P', 'en-us') as markup_pct
from formatted_kpis )
select* from real_margins_kpis

--- 2.Discount Analysis
--- Average discount
select 
round(sum(t.quantity * p.list_price * (t.discount / 100.0)) * 100.0 / nullif(sum(t.quantity * p.list_price), 0), 
    2) as avg_discount_pct_by_revenue
from dbo.sales_data t
inner join dbo.product_data p
on p.product_id = t.product_id

--- Revenue taken by discount
SELECT 
     SUM(t.quantity * p.list_price)AS gross_revenue,
    SUM((t.quantity ) * p.list_price * (t.discount / 100.0))
    AS revenue_taken_by_discounts,
SUM((t.quantity - COALESCE(t.returned, 0)) * p.list_price * (1 - t.discount / 100.0))
AS net_revenue_after_discount,
case when SUM(t.quantity * p.list_price) > 0 then 
    round(SUM(t.quantity * p.list_price * (t.discount / 100.0)) / SUM(t.quantity * p.list_price) * 100, 2)
else 0
end as discount_revenue_lost_pct
FROM dbo.sales_data t
inner JOIN dbo.product_data p 
ON p.product_id = t.product_id

--- Price elasticity of demand (PED) = % change in quantity demanded / % change in price
with Full_price as (
select distinct year(date) as year, count(distinct customer_id) as count_customers_full_price,sum(quantity-coalesce(returned,0)) 
as net_quantity_full_price,
avg(list_price) as avg_price_full_price
from dbo.sales_data t
inner join dbo.product_data p
on p.product_id = t.product_id
where discount=0
group by year(date)
),
discounted as(
select distinct year(date) as year, count(distinct customer_id) as count_customers_discounted,sum(quantity-coalesce(returned,0))
as net_quantity_discounted,
avg(list_price * (1 - discount / 100.0)) as avg_price_discounted
from dbo.sales_data t
inner join dbo.product_data p
on p.product_id = t.product_id
where discount>0
group by year(date)
),
PED_calculation as (
select f.year, f.count_customers_full_price, d.count_customers_discounted,f.net_quantity_full_price, d.net_quantity_discounted,
f.avg_price_full_price,d.avg_price_discounted,
--- Calculate percentage change in quantity 
case when f.net_quantity_full_price > 0 then 
     (d.net_quantity_discounted - f.net_quantity_full_price) * 100.0 / f.net_quantity_full_price
else 0
end as percentage_change_in_quantity,
--- calculate percentage change in price 
case when f.avg_price_full_price > 0 
     then (d.avg_price_discounted - f.avg_price_full_price) * 100.0 / f.avg_price_full_price
else 0
end as percentage_change_in_price,
--- calculate PED
case when f.avg_price_full_price > 0 and f.net_quantity_full_price > 0
     then ((d.net_quantity_discounted - f.net_quantity_full_price) * 100.0 / f.net_quantity_full_price) / 
     ((d.count_customers_discounted - f.count_customers_full_price) * 100.0 / f.count_customers_full_price)
else 0
end as price_elasticity_of_demand
from Full_price f
left join discounted d
on f.year = d.year
)   
select * from PED_calculation
order by year asc
    
--- Average Transaction Value (ATV)
select sum(p.list_price * (t.quantity-coalesce(t.returned,0)) * (1 - t.discount / 100.0)) 
as net_revenue,
sum(p.list_price * (t.quantity-coalesce(t.returned,0)) * (1 - t.discount / 100.0)) /
count(distinct t.transaction_id) as average_transaction_value,
count(distinct t.transaction_id) as total_transactions
from dbo.sales_data t
inner join dbo.product_data p 
on p.product_id = t.product_id

--- Revenue by category
select distinct p.category,year(date) as year,
format(sum(p.list_price * (t.quantity-coalesce(t.returned,0)) * (1 - t.discount / 100.0)), 'C', 'en-US') 
as revenue_by_category,count(distinct t.customer_id) as total_customers,
count(distinct p.product_id) as total_products
from dbo.sales_data t
inner join dbo.product_data p
on p.product_id = t.product_id
group by p.category,year(date)
order by year(date) 

--- Revenue by region
select distinct s.region,year(date) as year,
format(sum(p.list_price * (t.quantity-coalesce(t.returned,0)) * (1 - t.discount / 100.0)), 'C', 'en-US') 
as revenue_by_region,count(distinct t.customer_id) as total_customers,
count(distinct p.product_id) as total_products
from dbo.sales_data t
inner join dbo.product_data p
on p.product_id = t.product_id
inner join dbo.store_data s
on s.store_id = t.store_id
group by s.region,year(date)
order by year(date) asc
 
 --- Revenue by season
 select distinct p.season,year(date) as year,count(distinct t.customer_id) as total_customers,
 format(sum(p.list_price * (t.quantity-coalesce(t.returned,0)) * (1 - t.discount / 100.0)), 'C', 'en-US')
 as revenue_by_season,count(distinct p.product_id) as total_products
 from dbo.sales_data t
 inner join dbo.product_data p
 on p.product_id = t.product_id
 group by p.season,year(date)
 order by year(date)

 --- Revenue by supplier
 select distinct p.supplier,year(t.date) as year,count(distinct t.customer_id) as total_customers,
 format(sum(p.list_price * (t.quantity-coalesce(t.returned,0)) * (1 - t.discount / 100.0)), 'C', 'en-US')
 as revenue_by_supplier,count(distinct p.product_id) as total_products
 from dbo.sales_data t
 inner join dbo.product_data p
 on p.product_id = t.product_id
 group by p.supplier,year(t.date)
 order by year(date)

 --- Revenue by age range
  select year(t.date) as year,
 case when age < 30 then 'Youth'
      when age between 30 and 45 then 'Adults'
      When age between 45 and 60  then 'Old'
      when age >60 then 'Seniors'
      else 'Unknown'
      end as age_range,
count(distinct t.customer_id) as total_customers,
format(sum(p.list_price * (t.quantity-coalesce(t.returned,0)) * (1 - t.discount / 100.0)), 'C', 'en-US')
 as revenue_by_age_range,count(distinct p.product_id) as total_products,
 round(sum(p.list_price * (t.quantity-coalesce(t.returned,0)) * (1 - t.discount / 100.0)) 
 / count(distinct t.customer_id), 2) as average_revenue_per_customer
 from dbo.sales_data t
 inner join dbo.product_data p
 on p.product_id = t.product_id
 inner join dbo.customer_data c
 on c.customer_id = t.customer_id
 group by case when age < 30 then 'Youth'
      when age between 30 and 45 then 'Adults'
      When age between 45 and 60  then 'Old'
      when age >60 then 'Seniors'
      else 'Unknown'
      end,year(t.date)
order by year(t.date)

--- Revenue by store
 select distinct  s.store_name,year(date) as year,count(distinct t.customer_id) as total_customers,
 format(sum(p.list_price * (t.quantity-coalesce(t.returned,0)) * (1 - t.discount / 100.0)), 'C', 'pt-PT')
 as revenue_by_store,count(distinct p.product_id) as total_products
 from dbo.sales_data t
 left join dbo.product_data p
 on p.product_id = t.product_id
 left join dbo.store_data s
 on s.store_id = t.store_id
 where store_name is not null
 group by  s.store_name,year(date)
 order by year(date)
 
--- year to year analysis 
select count(distinct(month(date)))
from dbo.sales_data
where date like '2024%'

--- previous year earnings compared to this year
with yearlyfunds as (
select distinct year(date) as year,sum((quantity -coalesce(returned,0)) *list_price *(1-discount/100.0))
as current_revenue,count(distinct customer_id) as total_customers,count(distinct t.product_id) as total_products,
count(distinct transaction_id) as total_transactions
from dbo.sales_data t
inner join dbo.product_data p
on p.product_id = t.product_id
group by  year(date)
),
year_aggregations as  (
select year,
format(current_revenue, 'C', 'pt-PT') as current_revenue,total_customers,total_products,total_transactions,
current_revenue / total_transactions as average_transaction_value,
LAG(current_revenue) OVER (ORDER BY year) as previous_year_revenue,
current_revenue - LAG(current_revenue) OVER (ORDER BY YEAR) as difference_revenue,
case when current_revenue - LAG(current_revenue) OVER (ORDER BY YEAR) > 0 then 'good_year'
     when current_revenue - LAG(current_revenue) OVER (ORDER BY YEAR) < 0 then 'bad_year'
 else 'same'
end year_comparison,
 (current_revenue - LAG(current_revenue) OVER (ORDER BY year)) * 100.0/LAG(current_revenue) OVER (ORDER BY year) 
 as yoy_growth_pct
from yearlyfunds
group by year,current_revenue,total_customers,total_products,total_transactions
)
select year, current_revenue,
format(previous_year_revenue, 'C', 'pt-PT') as previous_year_revenue,
format(difference_revenue, 'C', 'pt-PT') as difference_revenue,
year_comparison,
round(yoy_growth_pct, 2) as yoy_growth_pct,
total_customers,total_products,total_transactions,average_transaction_value
from year_aggregations

GO

--- year over year product sales behavior/trend
with yearly_product_revenue as (
select 
 p.product_id, p.category,t.date,
 year(t.date) AS sales_year,
 sum((t.quantity - coalesce(t.returned, 0)) * p.list_price * (1 - t.discount / 100.0)) as net_revenue,
 count(distinct t.transaction_id) AS total_transactions
 from dbo.sales_data t
 inner join dbo.product_data p 
 ON p.product_id = t.product_id
where p.product_id is not null
group by p.product_id, p.category, year(t.date),t.date
),
product_avg as
(
select 
product_id,
avg(net_revenue) AS avg_revenue_across_years,
datediff(month,min(date),max(date)) as lifespan_months
from yearly_product_revenue
group by  product_id
)
select 
y.product_id,y.category, y.sales_year,pa.lifespan_months, y.net_revenue, pa.avg_revenue_across_years,
 -- Difference from Average
 y.net_revenue - pa.avg_revenue_across_years as difference_from_avg,
 -- Above / Below Average
case when y.net_revenue > pa.avg_revenue_across_years then 'Above Average'
     when y.net_revenue < pa.avg_revenue_across_years then 'Below Average'
else 'Equal to Average'
end as  performance_vs_avg,
-- Previous Year Comparison
lag(y.net_revenue) over (partition by y.product_id order by y.sales_year) as previous_year_revenue,
case  when lag(y.net_revenue) over(partition by y.product_id order by y.sales_year) > 0 
      then (y.net_revenue - lag(y.net_revenue) over(partition by y.product_id order by y.sales_year)) 
                 * 100.0 
                 / lag(y.net_revenue)over(partition by y.product_id order by y.sales_year)
 else null 
end as  yoy_growth_pct,
 y.total_transactions
from yearly_product_revenue y
left join  product_avg pa 
on pa.product_id = y.product_id
order by y.product_id, y.sales_year




     

      
