select * from merch_sales;

describe merch_sales;


alter table merch_sales
rename column  `Product_category` to product_category;


ALTER TABLE merch_sales RENAME COLUMN `Order ID` TO order_id;
ALTER TABLE merch_sales RENAME COLUMN `Order Date` TO order_date;
ALTER TABLE merch_sales RENAME COLUMN `Product ID` TO product_id;
ALTER TABLE merch_sales RENAME COLUMN `Product Category` TO product_category;
ALTER TABLE merch_sales RENAME COLUMN `Buyer Gender` TO buyer_gender;
ALTER TABLE merch_sales RENAME COLUMN `Buyer Age` TO buyer_age;
ALTER TABLE merch_sales RENAME COLUMN `Order Location` TO order_location;
ALTER TABLE merch_sales RENAME COLUMN `International Shipping` TO international_shipping;
ALTER TABLE merch_sales RENAME COLUMN `Sales Price` TO sales_price;
ALTER TABLE merch_sales RENAME COLUMN `Shipping Charges` TO shipping_charges;
ALTER TABLE merch_sales RENAME COLUMN `Sales per Unit` TO sales_per_unit;
ALTER TABLE merch_sales RENAME COLUMN `Quantity` TO quantity;
ALTER TABLE merch_sales RENAME COLUMN `Total Sales` TO total_sales;
ALTER TABLE merch_sales RENAME COLUMN `Rating` TO rating;
ALTER TABLE merch_sales RENAME COLUMN `Review` TO review;




# step 1 : drop the two columns product id and order id from table and partition by
# rename the column names acccordingly

select distinct(product_category)
from merch_sales;

select * from merch_sales;


/* the problem statement

Understanding Customer Behavior:

Analyze how gender, age, and location affect what customers buy.
Tailor marketing to fit these patterns.
Improving Sales Performance:

Find top-performing products and optimize pricing/shipping.
Understand what drives total sales.
Using Ratings and Reviews:

Identify what customers like or dislike based on ratings.
Improve product quality and satisfaction.
Boosting Profitability:

Pinpoint profitable products and demographics.
Reduce costs like shipping to improve margins.
Optimizing International Shipping:

Study trends in shipping overseas.
Compare costs and sales between domestic and international orders.
Predicting Product Demand:

Forecast sales trends to manage inventory better.
Prepare for seasonal changes in demand.
Targeted Marketing by Gender/Age:

See who buys what (gender/age group).
Create personalized campaigns for maximum impact.
*/

# 1. Sales Trends Over Time
## Analyze how sales change over time to identify patterns or seasonality.

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    product_category,
    SUM(total_sales) AS total_sales,
    SUM(quantity) AS total_quantity
FROM
    merch_sales
GROUP BY DATE_FORMAT(order_date, '%Y-%m') , product_category
ORDER BY DATE_FORMAT(order_date, '%Y-%m') , total_sales DESC;

/*insights : As we can  see in below query result that ending of the year months like 
nov,dec and so on and start of the
year monts jan feb march etc. sales have hit the maximum potential and with sold quantity had also increased.
*/

##2. Top-Selling Products
## Find the best-selling products by category and revenue.

select product_category,
order_location,
sum(total_sales) as total_revenue,
sum(quantity) as total_quantity
from merch_sales
group by product_category,order_location
order by total_revenue desc, total_quantity desc limit 10;

/*Insights: As we can see in below query result that Clothing category Have high sales
and High sales in location like San francisco and new jersey. as result in this we can increase in 
shipping quality and accurate the product quality according 
to the customers neeeds that only give highs to us */

-- 3. Gender-Based Purchasing Trends
-- Compare purchasing behavior by gender.

select * from merch_sales;

select buyer_gender,product_category,
avg(sales_price) as avg_price,
sum(quantity) as total_quantity,
sum(total_sales) as total_Revenue
from merch_sales
group by buyer_gender,product_category
order by buyer_gender,total_Revenue desc;

-- insights : As we can see here that Females dominate purchases in clothing and ornaments, 
-- contributing ₹189,643 in total revenue with an average spend of ₹90 per transaction.

-- 4. Age Group Insights
-- Determine which age groups spend the most and on which product categories.
select
case 
when buyer_age < 18 then 'under 18'
when buyer_age between 18 and 30 then '18-30'
when buyer_age between 31 and 50 then '31-50'
else '50+'
end as AgeGroup,
product_category, sum(total_sales) as Total_Sales,
avg(rating) as avg_rating
from merch_sales
group by AgeGroup,product_category
order by Total_Sales desc;

/* 
Age Group 18-30 dominates Clothing sales, contributing ₹462,371 with an average rating of 3.50.
Age Group 31-50 shows lower Clothing sales, ₹174,830, but a similar rating of 3.51.
Ornaments perform better with 18-30, generating ₹111,277 (rating: 3.42), compared to ₹44,527 (rating: 3.50) for 31-50.
Other products have higher ratings across both groups, with 18-30 contributing ₹46,723 (rating: 3.58) and 
31-50 contributing ₹16,734 (rating: 3.59).
*/

-- 5. Ratings and Reviews Analysis
-- Understand how ratings impact sales and product categories.
select product_category,
round(avg(rating),2) as avg_rating,
sum(total_sales) as Total_sales,
count(review) as count_reviews
from merch_sales
where rating is not null
group by product_category
order by avg_rating desc,Total_sales desc; 

/*
Clothing: Highest sales (₹637,201) and reviews (3,704), with an average rating of 3.50.
Ornaments: Moderate sales (₹155,804) and reviews (2,256), with an average rating of 3.45.
Other: Lowest reviews (1,434) but moderate sales (₹63,457), with an average rating of 3.58.
*/


-- 6. Shipping Analysis (Domestic vs. International)
-- Compare domestic and international shipping sales.

select 
international_shipping as is_international,
product_category,
sum(total_sales) as total_sales,
avg(shipping_charges) as avg_ship_charges,
count(order_id) as total_orders
from merch_sales
group by international_shipping , product_category
order by total_sales desc;

/*
Insights:
Clothing dominates domestic sales with ₹385,358 from 2,577 orders, 
60% higher revenue than international sales, which generated ₹251,843 from 1,127 orders.

International sales of ornaments and other products outperform domestic sales in 
revenue by 35% and 2.5x, respectively, despite having fewer orders.

Shipping charges impact: International orders incur an average 
shipping cost of ₹47–₹49, while domestic orders have no shipping charges, 
driving higher domestic order volumes.
*/

-- 7. High-Value Customers
-- Identify customers with the highest spending.
select 
buyer_gender,
order_location,
sum(total_sales) as total_spending,
count(order_id) as total_orders
from merch_sales
group by buyer_gender, order_location
having sum(total_sales) > 1000
order by total_orders limit 10;

/*
Highest Spending: Female buyers in Sydney lead with the highest 
total spending of $11,847, making 46 purchases.
Most Orders: Female buyers in Liverpool placed the most orders, with a total of 63 orders, 
amounting to $10,175 in spending.
Consistent Spend: Female buyers in Mumbai and New Delhi spent $10,987 and $11,479 respectively, 
with 54 orders each, 
showcasing high and consistent spending behavior.
*/
-- 8. Profit Margin Analysis
-- Calculate profit margins for different product categories.
select product_category,
sum(sales_per_unit * quantity - shipping_charges) as total_profit,
sum(total_sales) as Total_revenue,
round((sum(sales_per_unit * quantity - shipping_charges) / sum(total_sales))*100,2) as profit_margin
from merch_sales
group by product_category
order by total_profit desc;

/* 
Clothing has the highest profit margin at 91.56%, generating ₹583,411 profit from ₹637,201 in revenue.
Ornaments contribute the second-highest profit margin at 78.23%, with a profit of ₹121,879 from ₹155,804 in revenue.
Other category has the lowest profit margin at 67.72%, generating ₹42,972 in profit from ₹63,457 in revenue.
*/
-- 9. International Market Trends
-- Analyze international markets' performance.

select 
order_location,
count(order_id) as total_orders,
sum(total_sales) as total_sales,
avg(shipping_charges) avg_shipcharges
from merch_sales
where international_shipping = 'Yes'
group by order_location
order by total_sales desc;

/*
Highest Total Orders and Sales: Manchester recorded the highest total orders (208) and sales (₹32,426), followed closely by Cardiff (205 orders, ₹32,397) and Sydney (184 orders, ₹48,049).

Average Shipping Charges: Sydney had the highest average shipping charges (₹100), while most other locations, including Mumbai and New Delhi, had average charges around ₹70.

Sales vs Orders: Despite having the highest number of orders, Toronto and Montreal had the lowest total sales (₹26,163 and ₹23,644, respectively), indicating lower average sales per order compared to other locations.
*/

-- 10. Demand Forecasting for Inventory
-- Predict demand by analyzing past trends.
select 
date_format(order_date, '%Y-%m') as month,
product_category,
sum(quantity) as total_quantity
from merch_sales
group by date_format(order_date, '%Y-%m'),product_category
order by date_format(order_date, '%Y-%m') desc;

/*

Key Insights:
Clothing Sales Consistency: Clothing consistently leads in total quantity sold each month, with the highest recorded sales in May 2024 (585 units) and a slight dip in November 2024 (68 units). Overall, the monthly sales trend for clothing shows significant fluctuation.

Ornaments Perform Steadily: Ornaments demonstrate steady sales across the months, with an increase in quantity sold from 177 in June 2024 to 340 in May 2024, peaking in July 2024 with 340 units. The sales are generally stable compared to other product categories.

Other Category Fluctuations: The "Other" product category shows a noticeable drop in November 2024 (31 units) compared to earlier months (e.g., 177 in October 2024). There’s a trend of decrease in sales volume, particularly towards the end of the year.

Summary:
Clothing leads consistently across the months but with some significant drops in November 2024.
Ornaments display steady growth, maintaining moderate sales figures.
Other categories show a declining trend, particularly in the latter months, which may suggest changing customer preferences or seasonal factors.
*/

