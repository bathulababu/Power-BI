# Walmart Sales Analysis with MySQL
# In this Analysis, I will Analyze the data of a popular store called 'walmart'.
# Which will give me the necessary insights.

-- Create a database called salesdatawalmart to the dataset. --
CREATE DATABASE IF NOT EXISTS salesdatawalmart;
USE salesdatawalmart;
  
-- create a table called SALES  and it columns
CREATE TABLE IF NOT EXISTS salesdatawalmart.sales(
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
	branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
	date DATE NOT NULL,
    time TIME NOT NULL,
	payment_method VARCHAR(15) NOT NULL,
    rating FLOAT(2, 1),
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity_sold INT NOT NULL);
    
SELECT * FROM salesdatawalmart.sales;

DESCRIBE salesdatawalmart.sales;

-- Adding Fact Columns Using Mathematical Calculations --
-- Adding The Cost of Goods sold (COGS) column
SELECT Unit_price, Quantity
FROM salesdatawalmart.sales;

ALTER TABLE salesdatawalmart.sales
ADD COLUMN COGS DECIMAL(10,2);

-- Multiplying the unit price by quantity --
SET SQL_SAFE_UPDATES = 0;
UPDATE salesdatawalmart.sales
SET COGS = Unit_price * Quantity;

SELECT COGS FROM salesdatawalmart.sales;

-- Adding the VAT Column which is 5% of COGS
SELECT COGS * 0.05 AS COGS FROM salesdatawalmart.sales;

ALTER TABLE salesdatawalmart.sales
ADD COLUMN VAT FLOAT(6, 4) NOT NULL;

UPDATE salesdatawalmart.sales
SET VAT = COGS * 0.05;

SELECT VAT FROM salesdatawalmart.sales;

-- Adding the gross profit column --
SELECT COGS + VAT AS gross_profit
FROM salesdatawalmart.sales;

ALTER TABLE salesdatawalmart.sales
ADD COLUMN gross_profit DECIMAL(12, 4) NOT NULL;

-- By summing the cogs column to vat column
UPDATE salesdatawalmart.sales
SET gross_profit = COGS + VAT;

SELECT gross_profit FROM salesdatawalmart.sales;

-- By subtracting the cogs column from the vat column --
SELECT COGS - VAT AS net_profit
FROM salesdatawalmart.sales;

-- Adding the net profit column 
ALTER TABLE salesdatawalmart.sales
ADD COLUMN net_profit DECIMAL(12, 4) NOT NULL;

UPDATE salesdatawalmart.sales
SET net_profit = COGS - VAT;

SELECT net_profit FROM salesdatawalmart.sales;

-- Adding the time of day column
SELECT time,
(CASE WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
      WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
      ELSE "Evening" END) AS time_of_day
FROM salesdatawalmart.sales;

ALTER TABLE salesdatawalmart.sales
ADD COLUMN time_of_day VARCHAR(20);

UPDATE salesdatawalmart.sales
SET time_of_day = 
(CASE WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
      WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
      ELSE "Evening" END);

SELECT time_of_day FROM salesdatawalmart.sales;

-- Adding the day name column --
SELECT date, DAYNAME(date) AS day_name
FROM salesdatawalmart.sales;

ALTER TABLE salesdatawalmart.sales
ADD COLUMN day_name VARCHAR(10);

UPDATE salesdatawalmart.sales
SET day_name = CASE
    WHEN date LIKE '%/%/%' 
         THEN DAYNAME(STR_TO_DATE(date, '%m/%d/%Y'))
    WHEN date LIKE '%-%-%'
         THEN DAYNAME(STR_TO_DATE(date, '%m-%d-%y'))
    ELSE NULL
END;

SELECT day_name FROM salesdatawalmart.sales;

-- Adding the month name column --
SELECT date, MONTHNAME(date) AS month_name
FROM salesdatawalmart.sales;

ALTER TABLE salesdatawalmart.sales
ADD COLUMN month_name VARCHAR(15);

UPDATE salesdatawalmart.sales
SET month_name = CASE
    WHEN date LIKE '%/%/%'
         THEN MONTHNAME(STR_TO_DATE(date, '%m/%d/%Y'))
    WHEN date LIKE '%-%-%'
         THEN MONTHNAME(STR_TO_DATE(date, '%m-%d-%y'))
    ELSE NULL
END;

SELECT month_name FROM salesdatawalmart.sales;

SELECT * FROM salesdatawalmart.sales;

-- Business Questions --
# 1. How many unique cities in MYANMAR?
SELECT DISTINCT city FROM salesdatawalmart.sales;

# 2. In which city is each branch?
SELECT DISTINCT city, branch FROM salesdatawalmart.sales;

-- Product Questions --
# 1. How many unique product lines does the sales data have?
SELECT product_line, COUNT(DISTINCT product_line) AS product_count
FROM salesdatawalmart.sales
GROUP BY product_line;

# 2. What is the most common payment method?
SELECT payment, COUNT(payment) AS payment_count
FROM salesdatawalmart.sales
GROUP BY payment
ORDER BY payment_count DESC;

# 3. What is the most selling product line?
SELECT product_line, COUNT(product_line) AS product_line_count
FROM salesdatawalmart.sales
GROUP BY Product_line
ORDER BY product_line_count DESC;

# 4. What is the total revenue month?
SELECT month_name AS month, SUM(net_profit) AS total_revenue
FROM salesdatawalmart.sales
GROUP BY month_name
ORDER BY total_revenue DESC;

# 5. What month had the largest COGS (cost of goods sold)
SELECT month_name AS month, SUM(cogs) AS cogs
FROM salesdatawalmart.sales
GROUP BY month_name
ORDER BY cogs DESC;

# 6. What product line had the largest revenue?
SELECT product_line, SUM(gross_profit) AS revenue_before_vat, SUM(net_profit) AS revenue_after_vat
FROM salesdatawalmart.sales
GROUP BY Product_line
ORDER BY revenue_before_vat DESC, revenue_after_vat;

# 7) What is the city with the largest revenue?
SELECT branch, city, SUM(gross_profit) AS revenue_before_vat, SUM(net_profit) AS revenue_after_vat
FROM salesdatawalmart.sales
GROUP BY branch, city
ORDER BY revenue_before_vat DESC, revenue_after_vat;

# 8) What product line had the largest VAT?
SELECT product_line, AVG(VAT) AS avg_tax, SUM(VAT) AS total_tax
FROM salesdatawalmart.sales
GROUP BY Product_line
ORDER BY avg_tax DESC;

# 9) Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average profit
SELECT AVG(net_profit) FROM salesdatawalmart.sales;

SELECT Product_line, AVG(net_profit) AS avg_profit
FROM salesdatawalmart.sales
GROUP BY Product_line;

SELECT product_line, AVG(net_profit) AS avg_profit,
(CASE WHEN AVG(net_profit) > '292.20801100' THEN 'Good'
      ELSE 'Bad' END) AS prodduct_line_status
FROM salesdatawalmart.sales
GROUP BY Product_line
ORDER BY avg_profit DESC;

ALTER TABLE salesdatawalmart.sales
ADD COLUMN product_line_status VARCHAR(10);

UPDATE salesdatawalmart.sales
SET product_line_status = CASE WHEN '292.20801100' < (SELECT AVG(net_profit)) THEN 'Good'
						       ELSE 'Bad' END;

SELECT product_line_status FROM salesdatawalmart.sales;

SELECT product_line, product_line_status, AVG(net_profit) AS avg_profit
FROM salesdatawalmart.sales
GROUP BY product_line, product_line_status
ORDER BY avg_profit DESC;

# 10) Which branch sold more products quantity than average product quantity sold?
SELECT branch, AVG(quantity) AS avg_quantity, SUM(quantity) AS total_auantity
FROM salesdatawalmart.sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM salesdatawalmart.sales); 

# 11) What is the most common product line by gender?
SELECT gender, product_line, COUNT(gender) AS total_count
FROM salesdatawalmart.sales
GROUP BY gender, product_line
ORDER BY total_count DESC;

# 12) What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating),2) avg_rating
FROM salesdatawalmart.sales
GROUP BY Product_line
ORDER BY avg_rating DESC;

-- Sales Questions -- 
# 1. Number of sales made in each time of day per weekday?
SELECT time_of_day, day_name, COUNT(*) AS total_sales
FROM salesdatawalmart.sales
GROUP BY time_of_day, day_name
ORDER BY total_sales DESC;

# 2) Which of the customer types brings the most revenue?
SELECT customer_type, SUM(gross_profit) AS revenue_before_vat, SUM(net_profit) AS revenue_after_vat
FROM salesdatawalmart.sales
GROUP BY customer_type 
ORDER BY revenue_before_vat DESC, revenue_after_vat;

# 3) Which city pays the highest tax percent / VAT (Value Added Tax)?
SELECT city, AVG(VAT) AS avg_vat, SUM(VAT) AS total_vat
FROM salesdatawalmart.sales
GROUP BY city
ORDER BY avg_vat DESC, total_vat;

# 4) Which customer type pays the most in VAT?
SELECT customer_type, AVG(VAT) AS avg_vat, SUM(VAT) AS total_vat
FROM salesdatawalmart.sales
GROUP BY customer_type
ORDER BY avg_vat DESC, total_vat;

-- Customer Questions -- 
# 1. How many unique customer types does the data have, --
# What is the most common customer type & --
# Which customer type buys the most?
SELECT DISTINCT customer_type, COUNT(*) AS customer_count
FROM salesdatawalmart.sales
GROUP BY customer_type
ORDER BY customer_type;

# 2) How many unique payment methods does the data have?
SELECT DISTINCT payment, COUNT(payment) AS payment_counts
FROM salesdatawalmart.sales
GROUP BY payment
ORDER BY payment_counts DESC;

# 3) What is the gender of most of the customers?
SELECT gender, COUNT(*) AS gender_count
FROM salesdatawalmart.sales
GROUP BY gender
ORDER BY gender DESC;

# 4) What is the gender distribution per branch?
SELECT gender, COUNT(*) AS gender_count
FROM salesdatawalmart.sales
WHERE branch = 'A'
GROUP BY gender
ORDER BY gender_count DESC;

# 5) Which time of day do customers give the most ratings?
SELECT time_of_day, SUM(rating) AS total_rating, AVG(rating) AS avg_rating
FROM salesdatawalmart.sales
GROUP BY time_of_day
ORDER BY total_rating DESC, avg_rating DESC;

# 6) Which time of day do customers give most ratings per branch?
SELECT branch, time_of_day, SUM(rating) AS total_rating, AVG(rating) AS avg_rating
FROM salesdatawalmart.sales
GROUP BY time_of_day, branch
ORDER BY total_rating DESC, avg_rating DESC;

# 7) Which day of the week has the best average and total ratings?
SELECT day_name, AVG(rating) AS avg_rating, SUM(rating) AS total_rating
FROM salesdatawalmart.sales
GROUP BY day_name
ORDER BY total_rating DESC, avg_rating DESC;

# 8) Which day of the week has the best average and total ratings per branch?
SELECT day_name, branch, AVG(rating) AS avg_rating, SUM(rating) AS total_rating
FROM salesdatawalmart.sales
GROUP BY day_name, branch
ORDER BY avg_rating DESC;



