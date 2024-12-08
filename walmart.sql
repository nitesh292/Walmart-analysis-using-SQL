-- Customer Analysis

-- Do members spend more than normal customers, and by how much?  
WITH spend AS (
    SELECT 
        SUM(CASE WHEN customer_type = 'member' THEN ROUND(total) END) AS member_spend,
        SUM(CASE WHEN customer_type = 'normal' THEN ROUND(total) END) AS normal_spend
    FROM walmart
)
SELECT 
    member_spend, 
    normal_spend, 
    (member_spend - normal_spend) AS difference
FROM spend;

-- For each gender, which product line is purchased the most?  
WITH gender_sales AS (
    SELECT 
        gender, 
        product_line AS most_purchased_product_line, 
        SUM(quantity) AS total_quantity,
        RANK() OVER (PARTITION BY gender ORDER BY SUM(quantity) DESC) AS rank_
    FROM walmart
    GROUP BY gender, product_line
)
SELECT 
    gender, 
    most_purchased_product_line, 
    total_quantity
FROM gender_sales
WHERE rank_ = 1;
Sales Analysis
sql
Copy code
-- Which branch has the highest quantity sold?  
SELECT branch, SUM(quantity) AS quantity_sold
FROM walmart
GROUP BY branch  
ORDER BY quantity_sold DESC
LIMIT 1;

-- What is the total sales performance on a month-wise basis?  
SELECT  
    MONTHNAME(date) AS month, 
    ROUND(SUM(total)) AS total_sales_month
FROM walmart
GROUP BY month;

-- What are the weekly sales trends?  
SELECT 
    DAYNAME(date) AS day, 
    ROUND(SUM(total)) AS total_sales
FROM walmart
GROUP BY day
ORDER BY total_sales DESC;

-- Top 3 most profitable hours  
SELECT 
    HOUR(time) AS hour, 
    ROUND(SUM(total)) AS hourly_sales
FROM walmart 
GROUP BY hour 
ORDER BY hourly_sales DESC
LIMIT 3;

-- Which time of the day is the most profitable?  
SELECT 
    CASE 
        WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(time) BETWEEN 18 AND 23 THEN 'Evening'
    END AS time_of_day,
    ROUND(SUM(gross_income), 2) AS total_profit
FROM walmart
GROUP BY time_of_day
ORDER BY total_profit DESC;



-- Product Analysis

-- What are the top 3 highest revenue-generating product lines?  
SELECT 
    product_line, 
    ROUND(SUM(total)) AS total_revenue
FROM walmart
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 3;

-- Which product line has the highest customer rating?  
SELECT 
    product_line, 
    MAX(rating) AS highest_rating
FROM walmart 
GROUP BY product_line;

-- Calculate total profit for each product line  
SELECT 
    product_line, 
    ROUND(SUM(gross_income)) AS total_profit
FROM walmart 
GROUP BY product_line
ORDER BY total_profit DESC;

-- Which product line has the highest average profit margin?  
SELECT 
    product_line, 
    ROUND(AVG(gross_income)) AS avg_profit 
FROM walmart 
GROUP BY product_line
ORDER BY avg_profit DESC;

-- Which product lines generate high income but low sales quantity?  
WITH product_performance AS (
    SELECT 
        product_line, 
        SUM(quantity) AS total_quantity, 
        SUM(gross_income) AS total_gross_income,
        AVG(gross_income / quantity) AS avg_income_per_unit
    FROM walmart
    GROUP BY product_line
),
thresholds AS (
    SELECT 
        AVG(total_quantity) AS avg_quantity, 
        AVG(total_gross_income) AS avg_income
    FROM product_performance
)
SELECT 
    p.product_line, 
    p.total_quantity, 
    p.total_gross_income, 
    p.avg_income_per_unit
FROM product_performance p
CROSS JOIN thresholds t
WHERE p.total_gross_income > t.avg_income 
  AND p.total_quantity < t.avg_quantity
ORDER BY p.total_gross_income DESC;

-- What is the top-performing product line in each branch?  
WITH top_product AS (
    SELECT 
        product_line, 
        branch, 
        ROUND(SUM(total)) AS total_sales, 
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY SUM(total) DESC) AS row_number
    FROM walmart
    GROUP BY product_line, branch
)
SELECT  
    branch, 
    product_line AS highest_sales_product_line, 
    total_sales
FROM top_product 
WHERE row_number = 1;