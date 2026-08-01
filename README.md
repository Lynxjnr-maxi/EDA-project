# Project Background
XYZ company is a full-range lifestyle brand headquartered in Portugal. It offers footwear, accessories, and clothes through multiple channels-online sites, physical stores, and third-party suppliers.

As the company expands, it generates  significant amounts of data in its sales operations, marketing efforts, and product performance that it seeks to use to improve its overall retail value. This project leverages SQL-based exploration to analyze and synthesize this data to uncover insights in order to improve XYZ's commercial success.

### Insights and Recommendations are provided in the following areas:

- Sales Trend Analysis: Evaluation of the sales trends across regions, products, stores, and suppliers (growth & underperforming segments)
- Measure Customer Behaviour: Analyze the customer spending patterns (ATV) per age group, seasonal preferences, their stay with us (lifespan), and recency.
- Evaluate Discount Strategies: The effectiveness through Price Elasticity of Demand(PED), impact on revenue, and profitability.
- Product Level Performance: Through metrics like gross margin, return rates, revenue contribution, and the listing lifespan.
  
The SQL queries utilized to inspect and perform quality checks can be found [here](https://github.com/Lynxjnr-maxi/EDA-project/blob/1f1ebe7e8ac69392c419473a20c8ffe393d63c41/Data%20Cleaning.sql).

The SQL queries used to create a customer report can be found [here](https://github.com/Lynxjnr-maxi/EDA-project/blob/9edc7870bee2309165a62bbdcba98d36cbbbbb41/Cutomer%20Report.sql).

The SQL queries used to create a product report can be found [here](https://github.com/Lynxjnr-maxi/EDA-project/blob/6eaf8f920e6f4023470fe018a91a3b6acdf9f536/Product%20Report.sql).

The SQL queries regarding various business questions can be found [here](https://github.com/Lynxjnr-maxi/EDA-project/blob/1dfdc687118d62d81ec4cef84831a48db26f5115/Business%20Metrics.sql).

# Data Structure 
The XYZ database structure, as shown below, contains four tables: Customers, Product, Sales, and Store, with a total of 125,005 rows and 25 columns.


   <img width="2138" height="1253" alt="Fashion Data ERD (1) (2)" src="https://github.com/user-attachments/assets/ddfcd01a-415c-43fd-88b8-95639f35ff57" />

# Executive Summary
## Overview Of Findings
Between 2020 and 2024, overall net revenue fluctuated due to external market conditions and shifting customer patterns.
Revenue declined from €2.27 M in 2020 to €2.22 M in 2022, reflecting pandemic‑related disruptions and the high return rate 4.15%, then rebounded by 3% in 2023 (€2.29 M) as post‑pandemic normalcy returned. A mild contraction in 2024 (€2.25 M) suggests renewed pressure from supply or pricing factors.
Despite this, the customer base remained stable throughout, averaging 7900 per year - a clear sign of strong retention and brand loyalty.
However, the Average Transaction Value(ATV) oscillated noticeably: when ATV dipped, so did the revenue and vice versa.
This pattern indicates that the company's performance was influenced more by changes in spending behavior rather than the number of transactions or the customer count.

<img width=100% height=auto alt="Screenshot 2026-05-21 111908" src="https://github.com/user-attachments/assets/f20a6e8c-8067-4bca-9f55-20e3d7afa5b0" />

More queries concerning the revenue per category, season, supplier, store name, and Cost Of Goods Sold can be found [here](https://github.com/Lynxjnr-maxi/EDA-project/blob/1dfdc687118d62d81ec4cef84831a48db26f5115/Business%20Metrics.sql).

## Discount Strategies
- Full-price buyers: stable and high- value segment
-  Discount buyers: smaller group, lower spending intensity
- PED average of +1.02 is technically elastic but contextually ineffective due to the drops in quantity purchased when discounted.
- Furthermore, looking at customer intensity, our Full-Price segment averages 2.80 units per customer, while the Discount segment converts at a lower 2.67 units per customer. Lowering prices did not incentivize deeper shopping carts.
- Conclusion: Discount eroded margins, i.e 5.5% of total revenue, without expanding demand (quantity purchased); hence, the promotion did not meet its intended impact.

<img width=200% height=100% alt="Screenshot 2026-05-21 122506" src="https://github.com/user-attachments/assets/6372f288-45da-4567-9980-53ec2a4e93a3" />

## Product Performance

With a cumulative total of 24,911 products and 5 categories, XYZ product portfolio is vast.
- The Accessories category stands out, leading in both revenue generation (20.17%), client engagement, as well as products stocked
  while the Dresses category has the highest gross margin of 24.69%.
- Lisbon Metropolitan Area got the lowest sales of all four regions, accounting for only 16% of sales, while the rest divide the pie almost equally.

 # Customer Behavior Analysis
- XYZ’s clientele spans a wide age range, from 16 to 69 years old.
- Customer retention is strong, with 77% of customers remaining for more than a year, highlighting loyalty and sustained engagement.
- Revenue contribution by age group shows clear differences in purchasing power:
    - Adults: 28.8% — the largest share, driven by higher disposable income and consistent purchasing.
    - Old: 26.1% — a stable, high‑value segment.
    - Youth: 24.7% — important for growth and future retention.
    - Seniors: 16% — the smallest share, but still a meaningful contributor.
  
# Recommendations
Based on the uncovered insights, the following recommendations have been provided:
- Strategic Discounting  
The PED value of +1.10 suggests elasticity, but in practice, discounts were ineffective because the quantity of products purchased fell. Blanket price cuts should be avoided. Instead, implement targeted discounts such as one‑on‑one offers for repeat customers, loyalty rewards, or personalized bundles that protect margins while rewarding high‑value buyers.
- Capitalize on High‑Margin Products  
Certain products, like Product ID 9535, demonstrated viable revenue despite being stocked only once. Similarly, dresses show low COGS and high margins. These categories should be prioritized in marketing campaigns and inventory planning to maximize profitability.
- Reassess 2024 Pricing Strategy  
The −2% revenue drop in 2024 occurred despite favorable market conditions. The only significant internal change was a reduction in listed products (from 9,101 to 8,969). This suggests profitable items were pulled prematurely. Pricing and product availability should be re‑evaluated to ensure that high‑performing products remain accessible to customers.
- Although seniors contribute the least revenue, they represent a strategic opportunity. This can be exploited by:
     - Product tailoring of comfortable footwear and accessories designed for practicality.
     - Simplifying online navigation and offering personalized support in physical stores to make shopping easier
 
# Assumptions and Caveats
Throughout the analysis, multiple assumptions were made to manage challenges with the data. These assumptions and caveats are noted below:
- The Null values were not included in the calculations
- The 999 store_id in the dbo.sales_data table was missing in the dbo.store_data table, hence it was not included in the calculations.







