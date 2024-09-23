/*
SELECT	... columns: dimensions, (aggregated) measures
FROM	... tables
WHERE	... filter rows before grouping
GROUP BY... group rows by dimensions
HAVING	... filter rows after grouping
ORDER BY... sort rows by columns: ascending or descending
LIMIT	... rank rows: bottom n or top n

Golden Rules
1. Dimensions in SELECT statement must appear in GROUP BY statement.
2. Measures in SELECT statement must be used in an aggregate function: SUM, AVG, MAX, MIN, COUNT, DISTINCT.
*/

set global local_infile = 1;

-- ############ create a database ############

DROP DATABASE IF EXISTS coffee_chain;
CREATE DATABASE coffee_chain;
USE coffee_chain; 

-- ############ create tables ############
  
CREATE TABLE Product (
	Product_Id VARCHAR(255),
    Product VARCHAR(255),
    Product_Type VARCHAR(255),
    Product_Category VARCHAR(255),
	PRIMARY KEY (Product_Id));
    
CREATE TABLE Location (
	Area_Code CHAR(3),
    State VARCHAR(255),
    Market VARCHAR(255),
    Market_Size VARCHAR(255),
	PRIMARY KEY (Area_Code));

CREATE TABLE Date (
	Date DATE,
    Month CHAR(6),
    Quarter CHAR(6),
    Year CHAR(4),
	PRIMARY KEY (Date));

CREATE TABLE Fact (
	Product_Id VARCHAR(255),
    Area_Code CHAR(3),
    Date DATE,
    Sales INTEGER,
    COGS INTEGER,
    Margin INTEGER,
    Expenses INTEGER,
    Profit INTEGER,
    Marketing INTEGER,
    Inventory INTEGER,
    Budget_Sales INTEGER,
    Budget_COGS INTEGER,
    Budget_Margin INTEGER,
    Budget_Profit INTEGER,
    FOREIGN KEY (Product_Id) REFERENCES Product (Product_Id),
    FOREIGN KEY (Area_Code) REFERENCES Location (Area_Code),
    FOREIGN KEY (Date) REFERENCES Date (Date));

-- ############ load data ############

-- MAC User need to change path to be "/usr/.../file"
LOAD DATA LOCAL INFILE 'path/to/Product.csv'
INTO TABLE Product
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- MAC User need to change path to be "/usr/.../file"
LOAD DATA LOCAL INFILE 'path/to/Location.csv'
INTO TABLE Location
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- MAC User need to change path to be "/usr/.../file"
LOAD DATA LOCAL INFILE 'path/to/Date.csv'
INTO TABLE Date
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- MAC User need to change path to be "/usr/.../file"
LOAD DATA LOCAL INFILE 'path/to/Fact.csv'
INTO TABLE Fact
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


--1. Which Area Code was 25th place in Sales for Espresso? 318
--step 1, filter rows: Product_Type = 'Espresso'
--step 2, sum Sales group by Area_Code
--step 3, sort rows by Sales descending
--step 4, rank rows: no. 25 (limit 1 offset 24)



--2. Which State in the East Market has the lowest Profit for Espresso? New Hampshire
--step 1, filter rows: Product_Type = 'Espresso', Market = 'East'
--step 2, (aggregate) Profit (group) by State
--step 3, sort rows by Profit ascending
--step 4, rank rows: top 1 (limit 1)



--3. What is the difference in Budget Profit, in 2012Q3 from the previous quarter for Major Market? 630
--step 1, filter rows: Market_Size = 'Major Market'
--step 2. (aggregate) Budget_Profit (group) by Quarter
--step 3. add previous row Budget_Profit to current row
--step 4. calculate (current row Budget_Profit - previous row Budget_Profit) for every row
--step 5. filter rows: Quarter = '2012Q3'



--4. In which Month did the running Sales cross $30,000 for Decaf in Colorado and Florida? 201305
--step 1, filter rows: Product_Category = 'Decaf', State in ('Colorado', 'Florida')
--step 2. (aggregate) Sales (group) by Month
--step 3. calculate running Sales for every row
--step 4. filter rows: running Sales >= 30,000
--step 5, add row number to every row
--step 6. filter rows: row number = 1



--5. In 2013, identify the State with the highest Profit in the West Market? California
--step 1, filter rows: Market = 'West', Year = '2013'
--step 2. (aggregate) Profit (group) by State
--step 3, sort rows by Profit descending
--step 4, rank rows: top 1 (limit 1)



--6. Identify the % Expenses / Sales of the State with the lowest Profit. 45.58%
--step 1. (aggregate) Profit, (calculate measure) Expenses_To_Sales_Ratio (group) by State
--step 2, sort rows by Profit ascending
--step 3, rank rows: top 1 (limit 1)



--7. Create a Combined Field with Product and State. Identify the highest selling Product and State. (Colombian, California), (Colombian, New York)
--step 1, create Product_State
--step 2, (aggregate) Sales (group) by Product_State
--step 3, add rank number to every row (the same rank number to the same value) 
--step 4, filter rows: rank number = 1

-- row_number() attributes a unique value to each row
-- rank() attributes the same rank to the same value, leaving 'holes'
-- dense_rank() attributes the same rank to the same value, leaving no 'holes'
/*
+--------+------------+------+------------+
| Salary | row_number | rank | dense_rank |
+--------+------------+------+------------+
|    300 |          1 |    1 |          1 |
|    200 |          2 |    2 |          2 |
|    200 |          3 |    2 |          2 |
|    100 |          4 |    4 |          3 |
+--------+------------+------+------------+
*/



--8. What is the contribution of Tea to the overall Profit in 2012? 20.42%
--step 1, filter rows: Year = '2012'
--step 2. (aggregate) Profit (group) by Product_Type
--step 3. add Total Profit to every row
--step 4, calculate Profit as % of Total Profit for every row
--step 5, filter rows: Product_Type = 'Tea'



--9. What is the average % Profit / Sales for all the Products starting with C? 34.52%
--step 1. (calculate measure) Profit_To_Sales_Ratio
--step 2, filter rows: Products starting with C



--10. What is the distinct count of Area Codes for the State with the lowest Budget Margin in Small Market? 1
--step 1, (aggregate) Budget_Margin, Area_Code (group) by State
--step 2, filter rows: Market_Size = 'Small Market'
--step 3, sort rows: (aggregated) Budget_Margin ascending
--step 4, rank rows: top 1 (limit 1)



--11. Which Product Type does not have any of its Product within the Top 5 Products by Sales? Tea
--step 1, (aggregate) Sales (group) by Product_Type, Product
--step 2, sort rows by sales descending
--step 3, rank rows: top 5 (limit 5) 
--step 4, distinct Product_Types that have Product(s) among top 5 
--step 5, distinct Product_Type that doesn't have Product(s) among top 5 



--12. In the Central Market, the Top 5 Products by Sales contributed _% of the Expenses. 60.92% 
--step 1, filter rows: Market = 'Central'
--step 2, (aggregate) Sales, Expenses (group) by Product
--step 3, sort rows by Sales descending
--step 4, calculate running Expenses for every row
--step 5, add total Expenses to every row
--step 6, calculate running Expenses as % of total Expenses to every row,
--step 7, add row number to every row
--step 8, filter rows: row number = 5, running Expenses of top 5 selling products as % of total Expenses