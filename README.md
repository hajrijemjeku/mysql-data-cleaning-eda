# Layoffs Data Cleaning & Exploratory Data Analysis

This project focuses on cleaning and exploring a dataset containing company layoffs using **MySQL**. The analysis follows a practical data analysis workflow, beginning with data cleaning and preparation and continuing with exploratory data analysis (EDA) to identify trends, patterns, and insights within the data.

The data-cleaning phase was completed using SQL to investigate data quality issues, remove duplicate records, standardize inconsistent values, handle missing data, and prepare the dataset for further analysis.


# Project Objective

The objective of this project is to apply practical SQL skills to a real-world dataset and develop a structured data analysis workflow.

The project aims to:

* Clean and prepare the layoffs dataset for analysis.
* Identify and remove duplicate records.
* Standardize inconsistent values and formats.
* Handle missing and blank values appropriately.
* Convert data into suitable datatypes for analysis.
* Explore the cleaned dataset to identify trends, patterns, and relationships.
* Generate meaningful insights from the data using SQL.


# Project Workflow

The project follows a structured data analysis workflow:

**Raw Data → Data Cleaning → Exploratory Data Analysis → Insights**

### 1. Data Cleaning

The original dataset is preserved as raw data, while staging tables are used for data cleaning and preparation before performing exploratory analysis.

### Dataset Source

The dataset was obtained from **Kaggle**:

**Layoffs 2022:** https://www.kaggle.com/datasets/swaptr/layoffs-2022

The dataset was imported into MySQL and used as the starting point for the data-cleaning and exploratory analysis process.



The cleaning process includes:

* Identifying and removing duplicate records.
* Standardizing inconsistent text values.
* Removing unnecessary whitespace.
* Converting the date column from text to the `DATE` datatype.
* Investigating missing and blank values.
* Populating missing values only when reliable information is available.
* Removing records where both `total_laid_off` and `percentage_laid_off` are missing.

### 2. Exploratory Data Analysis

After cleaning the dataset, exploratory data analysis was performed using SQL to identify trends, patterns, and notable observations in the layoffs data.

The analysis examined the dataset from several perspectives, including:

* The largest individual layoff records.
* Companies that reported laying off 100% of their workforce.
* Companies with the highest total number of recorded layoffs.
* The overall time range covered by the dataset.
* Layoffs by industry and country.
* Total layoffs recorded by year and month.
* Layoffs by company funding stage.
* Monthly and yearly cumulative layoffs.
* Company-level layoffs across different years.
* The companies with the highest number of layoffs in each year.

The EDA was performed progressively, using the results of earlier queries to guide further exploration and identify potentially interesting patterns in the data.




# Dataset

The dataset used in this project is the Layoffs 2022 dataset from Kaggle, which contains information about company layoffs across different industries, locations, and countries. Although the dataset is named "Layoffs 2022," the dataset version used in this project contains records extending through August 2026.

The dataset includes the following columns:

| Column                | Description                                    |
| --------------------- | ---------------------------------------------- |
| `company`             | Name of the company                            |
| `location`            | Location associated with the company           |
| `total_laid_off`      | Total number of employees laid off             |
| `date`                | Date of the reported layoffs                   |
| `percentage_laid_off` | Percentage of the company's workforce laid off |
| `industry`            | Industry in which the company operates         |
| `source`              | Source of the layoff information               |
| `stage`               | Company's funding or development stage         |
| `funds_raised`        | Total funds raised by the company              |
| `country`             | Country associated with the company            |
| `date_added`          | Date the record was added to the dataset       |

The original dataset is preserved as raw data, while staging tables are used for data cleaning and preparation before performing exploratory analysis.


# Data Cleaning

The data-cleaning phase was performed using staging tables to ensure that the original raw dataset remained unchanged. The goal was to identify data-quality issues and prepare a reliable dataset for exploratory analysis.

### Creating Staging Tables

A copy of the original `layoffs` table was created as `layoffs_staging`. All cleaning operations were performed on the staging tables rather than the raw table.

A second staging table, `layoffs_staging2`, was created to identify and remove duplicate records.

### Removing Duplicates

The dataset did not contain a unique identifier that could be used to identify duplicate records.

`ROW_NUMBER()` with `PARTITION BY` was therefore used across multiple columns that together describe a layoff record. Records with a `row_num` greater than 1 were identified as duplicates and removed.

### Standardizing Data

The dataset was examined for inconsistent values and formatting.

* Leading and trailing whitespace was found in **16 company records** and removed using `TRIM()`.
* `UAE` was standardized to `United Arab Emirates`.
* The `industry`, `stage`, `location`, and `country` values were examined for other inconsistencies.

### Converting the Date Column

The `date` column was originally stored as text. The values were converted from text to date values using `STR_TO_DATE()`, after which the column datatype was changed to `DATE`.

This ensures that the date column can be used correctly for time-based analysis during the EDA phase.

### Converting Numeric Columns

The `total_laid_off` and `funds_raised` columns were originally stored as text. Their values were inspected before changing the datatypes.

* Empty strings in `total_laid_off` were converted to `NULL`, and the column was changed to `INT` because the number of employees is a whole-number value.
* Empty strings in `funds_raised` were converted to `NULL`, and the column was changed to `DECIMAL(10,4)` to preserve values containing decimal places.

This ensures that both columns can be used correctly for numerical calculations during the EDA phase.

### Handling Missing Values

Missing and blank values were investigated to determine whether they could be reliably populated.

Two records had missing `industry` values. These records were investigated using matching company and location information, but no reliable values were found, so the missing values were left unchanged rather than making unsupported assumptions.

Records where both `total_laid_off` and `percentage_laid_off` were blank were considered unusable for analyzing the scale of layoffs. **741 such records were removed**.

The deletion was then verified to ensure that no records remained with both layoff measures blank.

### Result

The cleaned dataset is stored in `layoffs_staging2` and will be used as the basis for the exploratory data analysis phase.


# Exploratory Data Analysis

### Overall Dataset Overview

The first step of the EDA was to examine the overall time period covered by the dataset.

The cleaned dataset contains layoff records from **March 11, 2020 to August 12, 2026**. This provides a broad time range for analyzing how layoffs changed over different periods.

The date range was identified using the minimum and maximum values of the `date` column:

```sql
SELECT MIN(date), MAX(date)
FROM layoffs_staging2;
```

This time range was used as a starting point for further analysis of layoffs by year and month.

### Largest Layoffs

The next step was to identify the largest layoff events recorded in the dataset.

The maximum values of `total_laid_off` and `percentage_laid_off` were calculated to determine the largest number of employees laid off in a single record and the highest percentage of a workforce laid off.

```sql
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
```

The analysis also identified companies where **100% of the workforce was laid off**:

```sql
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1.0;
```

These records represent companies that reported laying off 100% of their workforce, making them particularly severe layoff events. Examining these companies provides additional context about the most severe layoff events in the dataset.

The records were also ordered by `funds_raised` to examine whether companies reporting 100% workforce layoffs had previously raised substantial amounts of funding.

### Companies With the Most Total Layoffs

The next analysis examined which companies had the highest total number of recorded layoffs across the dataset.

The `SUM()` function was used to calculate the total layoffs for each company, and the results were sorted in descending order.

```sql
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
```

The results show that **Amazon** had the highest total number of recorded layoffs, with **59,291**, followed by **Intel** with **43,115** and **Meta** with **35,700**.

This analysis helps identify the companies that contributed the largest number of recorded layoffs across the entire period covered by the dataset.

### Layoffs by Industry

The analysis was then expanded to examine how layoffs were distributed across different industries.

The total number of recorded layoffs was calculated for each industry using `SUM(total_laid_off)` and grouped by `industry`.

```sql
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
```

The results show that **Other** had the highest number of recorded layoffs, with **115,800**, followed by **Retail** with **108,226** and **Hardware** with **105,200**.

This analysis provides an overview of which industries experienced the largest number of recorded layoffs during the period covered by the dataset.

### Layoffs by Country

The analysis was then used to examine how layoffs were distributed across different countries.

The total number of recorded layoffs was calculated for each country using `SUM(total_laid_off)` and grouped by `country`.

```sql
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
```

The results show that the **United States** had the highest number of recorded layoffs, with **659,609**, followed by **India** with **66,909** and **Germany** with **32,055**.

This analysis highlights the countries with the largest number of recorded layoffs in the dataset and provides a geographic perspective on the overall layoff trends.

### Layoffs by Year

The next analysis examined how the total number of recorded layoffs changed from year to year.

The `YEAR()` function was used to extract the year from the `date` column, and the total layoffs were calculated for each year.

```sql
SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 DESC;
```

The results show that **2023** had the highest number of recorded layoffs, with **265,660**, followed by **2022** with **164,319** and **2024** with **152,922**.

The lowest annual total was recorded in **2021**, with **15,823** layoffs.

This analysis shows that the number of recorded layoffs varied significantly across the years, with a particularly large increase during 2022 and 2023.

### Layoffs by Funding Stage

The analysis was then expanded to examine the total number of recorded layoffs by company funding or development stage.

The total layoffs were calculated for each `stage` using `SUM(total_laid_off)`.

```sql
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
```

The results show that companies classified as **Post-IPO** accounted for the highest number of recorded layoffs, with **583,954** layoffs. Companies with an **Unknown** stage accounted for **82,438**, followed by **Acquired** companies with **74,442**.

This analysis provides insight into how recorded layoffs were distributed across different stages of company development and ownership.

### Monthly Layoffs

The next analysis examined how layoffs were distributed over time at a monthly level.

The year and month were extracted from the `date` column using `SUBSTRING()`, and the total number of recorded layoffs was calculated for each month.

```sql
SELECT SUBSTRING(date, 1, 7) AS month, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(date, 1, 7) IS NOT NULL
GROUP BY month
ORDER BY 1 ASC;
```

The results show substantial variation in monthly layoffs. The highest monthly total in the dataset occurred in **January 2023**, with **89,709** recorded layoffs. Other major peaks occurred in **November 2022**, with **53,594**, and **February 2023**, with **40,002**.

This analysis helps identify specific periods when layoffs increased significantly and provides a more detailed view of the trends observed in the yearly analysis.

### Monthly Rolling Total

After examining layoffs by month, a cumulative total was calculated to show how the total number of recorded layoffs accumulated over time.

A Common Table Expression (CTE) was used to first calculate total layoffs for each month. A window function with `SUM() OVER()` was then used to calculate the cumulative total.

```sql
WITH monthly_layoffs AS 
(
    SELECT SUBSTRING(date, 1, 7) AS month,
           SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(date, 1, 7) IS NOT NULL
    GROUP BY month
)
SELECT month,
       total_off,
       SUM(total_off) OVER(ORDER BY month) AS monthly_layoffs
FROM monthly_layoffs;
```

The cumulative total increases as each month's layoffs are added to the previous total. By the end of the dataset's period, the cumulative number of recorded layoffs reached **928,658**.

This analysis makes it easier to see how the overall number of recorded layoffs accumulated throughout the dataset's time period.

### Yearly Rolling Total

A yearly cumulative total was also calculated to examine how the overall number of recorded layoffs accumulated from year to year.

A Common Table Expression (CTE) was used to calculate the total layoffs for each year. A window function with `SUM() OVER()` was then used to calculate the cumulative total.

```sql
WITH yearly_layoffs AS 
(
    SELECT SUBSTRING(date, 1, 4) AS year,
           SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(date, 1, 4) IS NOT NULL
    GROUP BY year
)
SELECT year,
       total_off,
       SUM(total_off) OVER(ORDER BY year) AS yearly_layoffs
FROM yearly_layoffs;
```

The results show how the cumulative number of recorded layoffs increased each year. By August **2026**, the cumulative total reached **928,658** recorded layoffs.

The yearly rolling total provides a high-level view of how layoffs accumulated across the entire period covered by the dataset.

### Company-Year Rolling Total

The analysis was then extended to the company level to examine how layoffs accumulated over multiple years for individual companies.

First, the data was grouped by company and year to calculate the total number of layoffs recorded for each company in each year. A window function with `PARTITION BY company` was then used to calculate a cumulative total for each company across the years.

```sql
WITH company_layoffs AS 
(
    SELECT company,
           SUBSTRING(date, 1, 4) AS year,
           SUM(total_laid_off) AS total_off 
    FROM layoffs_staging2
    WHERE date IS NOT NULL 
    GROUP BY company, year
)
SELECT company,
       year,
       total_off,
       SUM(total_off) OVER (
           PARTITION BY company 
           ORDER BY year
       ) AS yearly_company_offs
FROM company_layoffs 
ORDER BY company, year;
```

This allows the analysis to show both the number of layoffs recorded for a company in a particular year and its cumulative layoffs up to that year.

For example, Amazon had **10,150** recorded layoffs in 2022, followed by additional layoffs in later years. Its cumulative total reached **59,291** by 2026.

This analysis helps identify companies that experienced layoffs across multiple years and shows how their cumulative recorded layoffs changed over time.

### Top 5 Companies by Year

The final analysis in this part of the EDA focused on identifying the companies with the highest number of recorded layoffs in each year.

A Common Table Expression (CTE) was first used to calculate the total layoffs for each company in each year. `DENSE_RANK()` was then used to rank companies within each year based on their total layoffs.

```sql
WITH company_year (company, years, total_laid_off) AS 
(
    SELECT company,
           SUBSTRING(date, 1, 4) AS year,
           SUM(total_laid_off) AS total_off 
    FROM layoffs_staging2
    WHERE date IS NOT NULL 
    GROUP BY company, year
),
company_year_rank AS 
(
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY years 
               ORDER BY total_laid_off DESC
           ) AS ranking
    FROM company_year
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;
```

The results show that the companies with the highest recorded layoffs changed considerably from year to year.

Because `DENSE_RANK()` was used, companies with the same number of layoffs receive the same ranking. As a result, some years may contain more than five companies in the result when there is a tie at the fifth rank.


Some notable examples include:

* **Uber** had the highest recorded layoffs in 2020, with **7,525**.
* **Bytedance** ranked first in 2021, with **3,600**.
* **Meta** ranked first in 2022, with **11,000**.
* **Amazon** ranked first in 2023, with **17,260**.
* **Intel** ranked first in 2024, with **15,062**.
* **Intel** ranked first in 2025, with **27,058**.
* **Oracle** ranked first in 2026, with **21,000**.

This analysis highlights which companies had the largest recorded layoff totals in each year and shows how the companies most affected by layoffs changed over time.

# Key Insights

The exploratory data analysis revealed several notable patterns in the layoffs dataset.

### Overall Trends

* The dataset covers layoff records from **March 2020 through August 2026**.
* A total of **928,658 recorded layoffs** are represented in the cleaned dataset.
* **2023** had the highest annual number of recorded layoffs, with **265,660**.
* **January 2023** was the month with the highest number of recorded layoffs, with **89,709**.

### Industry Trends

* **Other** had the highest number of recorded layoffs, with **115,800**.
* **Retail** followed with **108,226**.
* **Hardware** recorded **105,200** layoffs.
* These results show that layoffs were distributed across a wide range of industries rather than being concentrated in only one sector.

### Geographic Trends

* The **United States** had the highest number of recorded layoffs, with **659,609**.
* **India** followed with **66,909**, while **Germany** recorded **32,055**.
* The large difference between the United States and other countries indicates that the dataset is heavily concentrated on U.S. layoff records.

### Company Trends

* **Amazon** had the highest cumulative number of recorded layoffs in the dataset, with **59,291**.
* **Intel** followed with **43,115**, while **Meta** recorded **35,700**.
* The companies with the highest layoffs changed from year to year. For example, Uber led in 2020, Meta in 2022, Amazon in 2023, Intel in 2024 and 2025, and Oracle in 2026.

### Severe Layoff Events

The analysis also identified companies where **100% of the reported workforce was laid off**. These records represent particularly severe events and include companies that subsequently shut down or ceased operations.

Overall, the EDA demonstrates how SQL can be used to move from a cleaned dataset to meaningful analysis by examining layoffs across time, industries, countries, companies, and funding stages.

# Skills Demonstrated

This project demonstrates practical SQL and data analysis skills, including:

* Data cleaning and preparation
* Working with staging tables
* Identifying and removing duplicate records
* Handling `NULL` and blank values
* Standardizing inconsistent data
* Converting and working with different data types
* Using aggregate functions such as `SUM()`, `MIN()`, and `MAX()`
* Filtering and sorting data
* Grouping data with `GROUP BY`
* Using Common Table Expressions (CTEs)
* Using window functions such as `SUM() OVER()`
* Using `ROW_NUMBER()` to identify duplicates
* Using `DENSE_RANK()` to rank companies within each year
* Performing time-based analysis using dates
* Exploratory Data Analysis (EDA)
* Identifying trends and patterns in real-world data
* Translating SQL results into meaningful observations

# SQL Queries

The SQL queries used for this project are organized into two main parts:

### Data Cleaning

The data-cleaning queries cover:

* Creating staging tables
* Identifying duplicate records
* Removing duplicates
* Standardizing text values
* Cleaning whitespace
* Converting date and numeric values
* Handling missing and blank values
* Removing records with insufficient layoff information

### Exploratory Data Analysis

The EDA queries cover:

* Identifying the largest layoff events
* Finding companies that laid off 100% of their workforce
* Ranking companies by total layoffs
* Analyzing layoffs by industry and country
* Analyzing layoffs by year and month
* Analyzing layoffs by funding stage
* Calculating monthly and yearly rolling totals
* Analyzing company-level layoffs across years
* Ranking the top companies by layoffs for each year

The complete SQL queries used for the project are available in the repository's SQL files.
