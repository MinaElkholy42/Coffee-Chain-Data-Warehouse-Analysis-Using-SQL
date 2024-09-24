# Coffee Chain Data Warehouse Analysis Using SQL

**This report includes SQL queries and instructions associated with a "Coffee Chain" data warehouse project.**  
**It provides an overview of the steps involved in data analysis and the warehouse structure.**<br/><br/><br/>

## Project Overview

This project focuses on building a relational database for a coffee chain business. The goal is to analyze key performance metrics such as sales, costs, and profit margins across different products, locations, and timeframes. The provided SQL queries help organize, aggregate, and analyze the data, offering insights into top-performing products, markets, and budget comparisons.<br/><br/><br/>

## Key Components

### 1) Database Creation

The project begins by creating a database named `coffee_chain`. Four main tables are created: `Product`, `Location`, `Date`, and `Fact`. These tables represent the core elements of the business: product details, geographic locations, timeframes, and financial/sales data.<br/><br/>

### 2) Table Details

**The main tables used to perform the analysis and build the data warehouse from scratch include:**

- **Product Table:** Contains product-related data such as product ID, name, type, and category.
- **Location Table:** Stores location-related data, including state, market, and market size.
- **Date Table:** Manages the time dimension, with fields for date, month, quarter, and year.
- **Fact Table:** Serves as the fact table in a star schema, holding financial measures (sales, costs, margins, profits, inventory, etc.) and linking to the `Product`, `Location`, and `Date` tables.<br/><br/>

### 3) Data Loading

The queries include instructions to load CSV data into the `Product` table using the `LOAD DATA LOCAL INFILE` command. Other tables are similarly populated using structured data files.<br/><br/>

### 4) Data Analysis

**The queries perform various aggregation operations to extract business insights, such as:**

- Ranking products by sales.
- Identifying the top-performing markets.
- Calculating the contribution of top-selling products to total costs.
- Comparing actual sales, costs, and profits against budgeted figures.<br/><br/>

### 5) Analytical Steps

**The main operations and steps used to analyze the data and derive valuable insights include:**

- **Filtering and Aggregating:** Queries focus on grouping data by product, market, and date, and calculating aggregated values such as total sales and costs.<br/><br/>
- **Ranking and Sorting:** Products and locations are ranked based on performance metrics.<br/><br/>
- **Insights:** Advanced queries calculate metrics like the percentage contribution of top-selling products to total costs and identify the markets contributing most to overall sales.<br/><br/>
