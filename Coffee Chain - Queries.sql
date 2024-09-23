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

USE coffee_chain; 

-- ############ load data ############
set OPT_LOCAL_INFILE = 1;

-- MAC User need to change path to be "/usr/.../file"
LOAD DATA LOCAL INFILE 'Data/Product.csv'
INTO TABLE Product
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- MAC User need to change path to be "/usr/.../file"
LOAD DATA LOCAL INFILE 'Data/Location.csv'
INTO TABLE Location
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- MAC User need to change path to be "/usr/.../file"
LOAD DATA LOCAL INFILE 'Data/Date.csv'
INTO TABLE Date
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- MAC User need to change path to be "/usr/.../file"
LOAD DATA LOCAL INFILE 'Data/Fact.csv'
INTO TABLE Fact
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

/*
--1. Which Area Code was 25th place in Sales for Espresso? 318
--step 1, filter rows: Product_Type = 'Espresso'
--step 2, sum Sales group by Area_Code
--step 3, sort rows by Sales descending
--step 4, rank rows: no. 25 (limit 1 offset 24)
*/

SELECT Area_Code FROM Fact JOIN Product  ON fact.Product_ID = Product.Product_Id
WHERE Product_Type = 'Espresso' GROUP BY Area_Code
ORDER BY sum(Sales) DESC
LIMIT 1 OFFSET 24;



/*
--2. Which State in the East Market has the lowest Profit for Espresso? New Hampshire
--step 1, filter rows: Product_Type = 'Espresso', Market = 'East'
--step 2, (aggregate) Profit (group) by State
--step 3, sort rows by Profit ascending
--step 4, rank rows: top 1 (limit 1)

*/

SELECT State FROM Fact  JOIN Product ON Fact.Product_Id = Product.Product_id 
JOIN Location  ON Fact.Area_Code = Location.Area_Code
WHERE Product_Type = 'Espresso' AND Market = 'East' 
GROUP BY State 
ORDER BY SUM(Profit) ASC
LIMIT 1;



/*
--3. What is the difference in Budget Profit, in 2012Q3 from the previous quarter for Major Market? 630
--step 1, filter rows: Market_Size = 'Major Market'
--step 2. (aggregate) Budget_Profit (group) by Quarter
--step 3. add previous row Budget_Profit to current row
--step 4. calculate (current row Budget_Profit - previous row Budget_Profit) for every row
--step 5. filter rows: Quarter = '2012Q3'

*/

WITH budget_per_quarter AS (
    SELECT Quarter, SUM(Budget_Profit) AS total_budget_profit
    FROM Fact  JOIN Location ON Fact.Area_Code = Location.Area_Code JOIN Date  ON Fact.Date = Date.Date
    WHERE Market_Size = 'Major Market'
    GROUP BY Quarter
)

SELECT 
(SELECT total_budget_profit FROM budget_per_quarter WHERE Quarter = '2012Q3')  -
(SELECT total_budget_profit FROM budget_per_quarter WHERE Quarter = '2012Q2')
AS budget_profit_diff;


/*
--4. In which Month did the running Sales cross $30,000 for Decaf in Colorado and Florida? 201305
--step 1, filter rows: Product_Category = 'Decaf', State in ('Colorado', 'Florida')
--step 2. (aggregate) Sales (group) by Month
--step 3. calculate running Sales for every row
--step 4. filter rows: running Sales >= 30,000
--step 5, add row number to every row
--step 6. filter rows: row number = 1
*/
WITH FilteredSales AS (
    SELECT d.Month, SUM(f.Sales) AS TotalSales
    FROM FACT f JOIN DATE d ON f.Date = d.Date JOIN LOCATION l ON f.Area_Code = l.Area_Code
    JOIN PRODUCT p ON f.Product_ID = p.Product_ID
    WHERE p.Product_Category = 'Decaf'
    AND l.State IN ('Colorado', 'Florida')
    GROUP BY d.Month
),
RunningTotal AS (
    SELECT Month, SUM(TotalSales) OVER (ORDER BY Month) AS RunningSales
    FROM FilteredSales
)
SELECT Month FROM RunningTotal
WHERE RunningSales >= 30000
ORDER BY Month
LIMIT 1;

/*
--5. In 2013, identify the State with the highest Profit in the West Market? California
--step 1, filter rows: Market = 'West', Year = '2013'
--step 2. (aggregate) Profit (group) by State
--step 3, sort rows by Profit descending
--step 4, rank rows: top 1 (limit 1)

*/


SELECT State FROM Fact JOIN Location ON Fact.Area_Code = Location.Area_Code JOIN Date ON Fact.Date = Date.Date
WHERE Market = 'West' AND Year = '2013'
GROUP BY State
ORDER BY SUM(Profit) DESC
LIMIT 1;



/*
--6. Identify the % Expenses / Sales of the State with the lowest Profit. 45.58%
--step 1. (aggregate) Profit, (calculate measure) Expenses_To_Sales_Ratio (group) by State
--step 2, sort rows by Profit ascending
--step 3, rank rows: top 1 (limit 1)

*/

SELECT  l.State,   CONCAT( CAST((SUM(f.Expenses) / SUM(f.Sales)) * 100 AS DECIMAL(5, 2)), "%") AS Expenses_To_Sales_Ratio
FROM Fact f JOIN Location l ON f.Area_Code = l.Area_Code
GROUP BY l.State
ORDER BY SUM(f.Profit) ASC  
LIMIT 1;  


/*
--7. Create a Combined Field with Product and State. Identify the highest selling Product and State. (Colombian, California), (Colombian, New York)
--step 1, create Product_State
--step 2, (aggregate) Sales (group) by Product_State
--step 3, add rank number to every row (the same rank number to the same value) 
--step 4, filter rows: rank number = 1

*/

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

with ProductStateSales as
(
	SELECT  CONCAT(Product, ', ', State) AS Product_State, SUM(Sales) AS Total_Sales
	FROM Fact JOIN Product ON Fact.Product_Id = Product.Product_Id JOIN Location ON Fact.Area_Code = Location.Area_Code
	GROUP BY Product_State
), 
RankedSales AS (
    SELECT Product_State,  Total_Sales, DENSE_RANK() OVER (ORDER BY Total_Sales DESC) AS Sales_Rank
    FROM ProductStateSales
)
SELECT Product_State, Total_Sales FROM RankedSales
WHERE Sales_Rank = 1
order by Product_State asc;


/*
--8. What is the contribution of Tea to the overall Profit in 2012? 20.42%
--step 1, filter rows: Year = '2012'
--step 2. (aggregate) Profit (group) by Product_Type
--step 3. add Total Profit to every row
--step 4, calculate Profit as % of Total Profit for every row
--step 5, filter rows: Product_Type = 'Tea'

*/


WITH TotalProfit2012 AS (
	SELECT SUM(Profit) AS TotalProfit FROM Fact JOIN Date ON Fact.Date = Date.Date
	WHERE Year = '2012'
),

TeaProfit2012 AS (
	SELECT SUM(Profit) AS TeaProfit FROM Fact JOIN Product ON Fact.Product_Id = Product.Product_Id
	JOIN Date ON Fact.Date = Date.Date
	WHERE Year = '2012' AND Product_Type = 'Tea'
)

SELECT CONCAT(CAST((TeaProfit2012.TeaProfit * 1.0 / TotalProfit2012.TotalProfit) * 100 AS DECIMAL (5, 2)), "%") AS TeaContribution
FROM TeaProfit2012, TotalProfit2012;


/*
--9. What is the average % Profit / Sales for all the Products starting with C? 34.52%
--step 1. (calculate measure) Profit_To_Sales_Ratio
--step 2, filter rows: Products starting with C

*/

SELECT  CONCAT(ROUND(SUM(f.Profit) / SUM(f.Sales) * 100, 2), "%") AS Avg_Profit_Percent
FROM Fact f JOIN Product p ON f.Product_Id = p.Product_Id
WHERE LOWER(p.Product) LIKE 'c%';

/*
--10. What is the distinct count of Area Codes for the State with the lowest Budget Margin in Small Market? 1
--step 1, (aggregate) Budget_Margin, Area_Code (group) by State
--step 2, filter rows: Market_Size = 'Small Market'
--step 3, sort rows: (aggregated) Budget_Margin ascending
--step 4, rank rows: top 1 (limit 1)

*/

SELECT COUNT(DISTINCT f.Area_Code) AS Distinct_Area_Code_Count FROM Fact f
JOIN Location l ON f.Area_Code = l.Area_Code JOIN Product p ON f.Product_Id = p.Product_Id
WHERE l.Market_Size = 'Small Market'
  AND l.State = (
  SELECT l.State FROM Fact f JOIN Location l ON f.Area_Code = l.Area_Code
  WHERE LOWER(l.Market_Size) = 'small market' GROUP BY l.State
  ORDER BY SUM(f.Budget_Margin) ASC LIMIT 1
);


/*
--11. Which Product Type does not have any of its Product within the Top 5 Products by Sales? Tea
--step 1, (aggregate) Sales (group) by Product_Type, Product
--step 2, sort rows by sales descending
--step 3, rank rows: top 5 (limit 5) 
--step 4, distinct Product_Types that have Product(s) among top 5 
--step 5, distinct Product_Type that doesn't have Product(s) among top 5 

*/

SELECT DISTINCT pt.Product_Type
FROM (
    SELECT  p.Product_Type,  f.Product_Id,  SUM(f.Sales) AS Total_Sales
    FROM Fact f JOIN Product p ON f.Product_Id = p.Product_Id
    GROUP BY p.Product_Type, f.Product_Id
) AS pt

WHERE pt.Product_Type NOT IN ( SELECT DISTINCT tableT.Product_Type 
FROM ( SELECT  p.Product_Type,  f.Product_Id, SUM(f.Sales) AS Total_Sales FROM Fact f
	   JOIN Product p ON f.Product_Id = p.Product_Id
	   GROUP BY p.Product_Type, f.Product_Id
	   ORDER BY Total_Sales DESC
	   LIMIT 5
    ) AS tableT
);


/*
--12. In the Central Market, the Top 5 Products by Sales contributed _% of the Expenses. 60.92% 
--step 1, filter rows: Market = 'Central'
--step 2, (aggregate) Sales, Expenses (group) by Product
--step 3, sort rows by Sales descending
--step 4, calculate running Expenses for every row
--step 5, add total Expenses to every row
--step 6, calculate running Expenses as % of total Expenses to every row,
--step 7, add row number to every row
--step 8, filter rows: row number = 5, running Expenses of top 5 selling products as % of total Expenses

*/


WITH CentralMarket AS (
	SELECT Product_Id, SUM(Sales) AS TotalSales, SUM(Expenses) AS TotalExpenses FROM Fact
	JOIN Location ON Fact.Area_Code = Location.Area_Code
	WHERE Market = 'Central'
	GROUP BY Product_Id
),

Top5Products AS (
	SELECT *, RANK() OVER (ORDER BY TotalSales DESC) AS ProductRank FROM CentralMarket
)

SELECT 
CONCAT(ROUND(SUM(TotalExpenses) * 1.0 / (SELECT SUM(Expenses) 
FROM Fact JOIN Location ON Fact.Area_Code = Location.Area_Code WHERE Market = 'Central') * 100, 2), "%") AS ContributionPercentage

FROM Top5Products
WHERE ProductRank <= 5;
