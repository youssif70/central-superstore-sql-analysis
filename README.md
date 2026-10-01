# Central Superstore — SQL Data Warehouse & Business Analytics

An end-to-end **SQL Server Data Warehouse and Business Analytics project** built using the Superstore dataset.

The project starts with raw transactional data, performs source exploration and data quality checks, transforms the data into a **Star Schema**, builds fact and dimension tables, and then uses SQL for business and advanced analytics.

---

## 🎯 Project Overview

The project follows an end-to-end data warehouse workflow:

**Source Data → Exploration → Data Quality → Star Schema → Fact & Dimensions → Warehouse Verification → Business Analytics → Advanced Analytics**

The main goal is to transform raw transactional sales data into a structured analytical model that can support business reporting and decision-making.

---

## 🏗️ Data Warehouse Architecture

The analytical model follows a **Star Schema**.

At the center of the model is the `fact_sales` table, connected to five dimension tables.

### ⭐ Fact Table

#### `fact_sales`

Contains the measurable sales transactions and foreign keys connecting the fact table to the dimensions.

Main fields include:

* `fact_key`
* `row_id`
* `order_id`
* `customer_key`
* `product_key`
* `location_key`
* `ship_mode_key`
* `order_date_key`
* `ship_date_key`
* `sales`
* `quantity`
* `discount`
* `profit`
* `shipping_duration`

### 📐 Dimension Tables

#### `dim_customer`

Contains customer-level information:

* Customer ID
* Customer Name
* Segment

#### `dim_product`

Contains product information:

* Product ID
* Product Name
* Category
* Sub-Category

#### `dim_location`

Contains geographic information:

* Country
* City
* State
* Postal Code
* Region

#### `dim_ship_mode`

Contains shipping method information.

#### `dim_date`

Contains date attributes used for time-based analysis:

* Full Date
* Year
* Quarter
* Month
* Month Name
* Day
* Day Name

---

## 🔍 1. Source Exploration

Before building the warehouse, the source table was explored to understand its structure and quality.

The analysis included:

* Inspecting sample records
* Counting total records
* Checking column names and data types
* Checking duplicate `Row ID` values
* Checking duplicate `Order ID` values
* Checking duplicate `Customer ID` values
* Checking duplicate `Product ID` values

---

## 🧹 2. Data Quality

A data quality check was performed across the main columns of the source dataset.

The checks included:

* Missing identifiers
* Missing dates
* Missing customer information
* Missing product information
* Missing geographic information
* Missing sales values
* Missing quantity
* Missing discount
* Missing profit
* Empty text values

This helped identify potential issues before loading the data into the warehouse.

---

## 🏗️ 3. Building the Star Schema

The warehouse was designed using a **Star Schema**.

The following tables were created:

```text
                    dim_customer
                         │
                         │
dim_product ─────── fact_sales ─────── dim_location
                         │
                         │
                  dim_ship_mode
                         │
                         │
                      dim_date
```

The fact table uses foreign keys to connect transactional records to the corresponding dimensions.

Surrogate keys were created using SQL Server `IDENTITY` columns for the main dimensions.

---

## 📥 4. Loading Dimension Data

Dimension tables were populated from the source table using SQL transformations.

Examples include:

* `DISTINCT` for dimension records
* `GROUP BY` for product-level consolidation
* `MAX()` for product attributes
* Date transformations for the Date Dimension
* Generating date keys in `YYYYMMDD` format

The Date Dimension was created using both:

* Order Date
* Ship Date

This allows the warehouse to support analysis across both types of dates.

---

## 📦 5. Building the Fact Table

The `fact_sales` table was created after the dimensions were populated.

The fact table connects to the dimensions through foreign keys.

The loading process uses multiple `INNER JOIN` operations to retrieve the appropriate dimension keys.

A derived metric was also created:

### Shipping Duration

```sql
DATEDIFF(day, order_date, ship_date)
```

This allows shipping performance to be analyzed directly from the fact table.

---

## ✅ 6. Warehouse Verification

After loading the warehouse, row counts were compared across:

* Source table
* `dim_customer`
* `dim_product`
* `dim_location`
* `dim_ship_mode`
* `dim_date`
* `fact_sales`

This step was used to verify the warehouse population and inspect the resulting fact table.

---

# 📊 Business Analytics

Once the Star Schema was built, the warehouse was used to answer business questions.

### Key Performance Indicators

The analysis calculates:

* Total Sales
* Total Profit
* Total Quantity
* Total Orders
* Total Customers
* Average Order Value
* Average Shipping Duration
* Profit Margin

### Product Analysis

* Sales by Category
* Profit by Category
* Sales by Sub-Category
* Top Products by Sales
* Top Products by Profit
* Loss-making Products

### Customer Analysis

* Sales by Customer Segment
* Top Customers by Sales
* Customer Profitability

### Geographic Analysis

* Sales by Region
* Profit by Region

### Shipping Analysis

* Sales by Ship Mode
* Profit by Ship Mode
* Average Shipping Duration by Ship Mode

### Time Analysis

* Yearly Sales
* Yearly Profit
* Monthly Sales
* Monthly Profit

---

# 🧠 Advanced SQL Analytics

The project also includes more advanced SQL techniques.

### CTE — Common Table Expressions

CTEs were used to organize intermediate calculations and make analytical queries easier to read.

Example use cases:

* Product sales calculations
* Category sales analysis
* Yearly sales analysis

### Window Functions

Window functions were used for analytical calculations such as:

* Product ranking
* Sales contribution
* Year-over-year growth

Examples include:

```sql
RANK()
LAG()
SUM() OVER()
```

### Sales Ranking

Products were ranked according to their total sales.

### Category Contribution

The percentage contribution of each category to total sales was calculated.

### Year-over-Year Growth

Yearly sales growth was calculated using `LAG()` to compare each year with the previous year.

---

# 📈 Final Analytical Output

After completing the SQL analysis, the results were exported and used to create the final analytical report.

The project contains:

* SQL analysis results
* Excel output
* Final PDF report
* Data visualizations
* Business insights

---

## 📂 Project Files

```text
central-superstore-data-warehouse/
│
├── README.md
│
├── sql/
│   └── central_superstore_analysis.sql
│
├── results/
│   └── central_superstore_results.xlsx
│
└── report/
    └── central_superstore_report.pdf
```

### SQL File

`central_superstore_analysis.sql`

Contains the complete SQL workflow:

* Source exploration
* Data quality checks
* Star Schema creation
* Dimension loading
* Fact table creation
* Warehouse verification
* Business analytics
* Advanced analytics
* Final Star Schema query

### Excel Results

`central_superstore_results.xlsx`

Contains the outputs generated from the analytical SQL queries.

### PDF Report

`central_superstore_report.pdf`

Contains the final visual report and the main analytical findings.

---

## 🛠️ Tools & Technologies

* **SQL Server**
* **T-SQL**
* **Excel**
* **Power BI**
* **Data Warehousing**
* **Dimensional Modeling**
* **Star Schema**
* **Business Intelligence**

---

## 💡 SQL Concepts Demonstrated

* Database and table exploration
* Data quality checks
* `CREATE TABLE`
* `INSERT INTO`
* `JOIN`
* `INNER JOIN`
* `GROUP BY`
* `HAVING`
* `CASE`
* `CTE`
* `RANK()`
* `LAG()`
* Window Functions
* Aggregate Functions
* Date Functions
* Foreign Keys
* Primary Keys
* Unique Constraints
* Surrogate Keys
* Dimensional Modeling

---

## 👤 Author

**Youssif Hassan**

Data Analyst | SQL | Power BI | Python | Excel

[GitHub](https://github.com/youssif70)
