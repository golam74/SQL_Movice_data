create table train_sales
(
	Date date,
	Category VARCHAR(20),
	Brand VARCHAR(10),
	Day_of_Week INT,
	Holiday_Indicator INT,
	Past_Purchase_Trends float,
	Price float,
	Discount float,
	Competitor_Price float,
	Sales_Quantity int
);
select * from train_sales
--Q1. The dataset contains daily transactions of different product categories and brands.
--Write a query to find the earliest purchase date and the most recent purchase date in the dataset.
--This will help us understand the data coverage period.
SELECT 
    MIN(Date) AS Earliest_Date,
    MAX(Date) AS Most_Recent_Date
FROM train_sales;

--Q2. Management wants to know how each brand is performing in terms of sales volume. 
--Write a query to calculate the total Sales_Quantity for each Brand, 
--and order the results in descending order of sales.
SELECT 
    Brand, 
    SUM(Sales_Quantity) AS Total_Sales
FROM train_sales
GROUP BY Brand
ORDER BY Total_Sales DESC;
--Q3. Holidays often impact customer purchases. 
--Retrieve all transactions where the Holiday_Indicator = 1 to analyze how sales behave during holiday periods.
select * from train_sales
where holiday_indicator =1;
--Q4. The company wants to understand weekly customer buying behavior. 
--Write a query to find the average Sales_Quantity for each Day_of_Week, 
--and then identify which day has the highest average sales.
select
	day_of_week, 
	avg(sales_quantity) as average_sales
from train_sales
group by day_of_week
order by average_sales desc
limit 1
--Q5. Revenue is a key metric for business analysis. 
--Write a query to calculate the total revenue (Price × Sales_Quantity) for each product Category,
--and show which category contributes the most to revenue.
select category, sum(price * sales_quantity) as Total_Revenue
from train_sales
group by category
order by total_Revenue desc
--Q6. Competitor pricing and discounts directly impact sales. 
--For each Brand, calculate the average Discount given and the average Competitor_Price, 
--so that we can compare our pricing strategy with the competition.
select brand, 
	avg(discount) as average_discount ,
	avg(competitor_price) as average_competitor_price
	from train_sales
	group by brand
order by average_discount desc,average_competitor_price desc
--Q7. The company wants to find the peak sales days.
--Write a query to list the Top 5 Dates with the highest total Sales_Quantity across all brands and categories.
select date,
	sum(sales_quantity) as date_Total_sales_quantity
	from train_sales
	group by date
	order by date_Total_sales_quantity desc
	limit 5
--Q8. To analyze the impact of holidays, 
--calculate the average Sales_Quantity on Holiday days vs Non-Holiday days and compare the results.
--Which type of day brings more sales?
SELECT 
    holiday_indicator, category,
    AVG(sales_quantity) AS avg_sales_quantity
FROM train_sales
GROUP BY holiday_indicator, category;
--Q9. Business leaders want to identify the top-performing brands. 
--Write a query using window functions to calculate the total revenue for each Brand and assign a rank based on total revenue, 
--with Rank 1 being the highest revenue brand.
SELECT 
    Brand,
   sum(price * sales_quantity) as Total_Revenue,
   rank() over (order by sum(price * sales_quantity)desc) as Rank_Revenue
   from train_sales
   group by brand
--pro tip category by nikal na hai to partition by category
SELECT 
    Category,
    Brand,
    SUM(Price * Sales_Quantity) AS Total_Revenue,
    RANK() OVER (PARTITION BY Category ORDER BY SUM(Price * Sales_Quantity) DESC) AS Revenue_Rank
FROM train_sales
GROUP BY Category, Brand;
--Q10. Sales trend analysis requires comparing daily sales movements. 
--For each Brand, use the LAG() function to calculate the difference between current day Sales_Quantity and the previous day Sales_Quantity. 
--This will help identify sudden increases or drops in sales.
select brand,
date,
sales_quantity,
	lag(sales_quantity)over (partition by brand order by date) as previous_sales_quantity,
	(sales_quantity - lag (sales_quantity) over (partition by brand order by date)) as sales_deff
	from train_sales
	order by brand,date
	
-- or null hatane ke liye
select brand,
date,
sales_quantity,
	coalesce(lag(sales_quantity)over (partition by brand order by date),0) as previous_sales_quantity,
	(sales_quantity - coalesce(lag (sales_quantity) over (partition by brand order by date),0)) as sales_deff
	from train_sales
	order by brand,date

--Q1. Holiday Impact on Sales

--Managers want to know whether holidays increase sales or not.
--👉 Write a query to calculate average sales quantity on holidays vs non-holidays for each Category.
select 
	category
	, holiday_indicator,
	avg(sales_quantity)
	from train_sales
group by category, holiday_indicator

--Q2. Price Elasticity

--Business wants to check if lowering price really increases sales.
--👉 For each Brand, calculate the correlation between Price and Sales_Quantity using SQL’s corr() function (Postgres supports it).
select category,
	round(corr(price,sales_quantity):: numeric,2) as Price_sales_corelation
	from train_sales
	group by category
	order by Price_sales_corelation asc
	
