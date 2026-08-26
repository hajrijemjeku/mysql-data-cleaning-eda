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

The original dataset is preserved as raw data. Staging tables are used to perform the cleaning process without modifying the original dataset.

The cleaning process includes:

* Identifying and removing duplicate records.
* Standardizing inconsistent text values.
* Removing unnecessary whitespace.
* Converting the date column from text to the `DATE` datatype.
* Investigating missing and blank values.
* Populating missing values only when reliable information is available.
* Removing records where both `total_laid_off` and `percentage_laid_off` are missing.

### 2. Exploratory Data Analysis

After the data-cleaning phase, the cleaned dataset will be explored using SQL to better understand its characteristics, identify patterns and relationships, and investigate interesting findings within the data.

The EDA process will be exploratory, meaning that observations from one analysis may lead to new questions and further investigation.

*This section will be expanded as the EDA phase is completed.*



# Dataset

The dataset used in this project is the **Layoffs 2022** dataset, which contains information about layoffs from companies across different industries, locations, and countries.

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

### Handling Missing Values

Missing and blank values were investigated to determine whether they could be reliably populated.

Two records had missing `industry` values. These records were investigated using matching company and location information, but no reliable values were found, so the missing values were left unchanged rather than making unsupported assumptions.

Records where both `total_laid_off` and `percentage_laid_off` were blank were considered unusable for analyzing the scale of layoffs. **741 such records were removed**.

The deletion was then verified to ensure that no records remained with both layoff measures blank.

### Result

The cleaned dataset is stored in `layoffs_staging2` and will be used as the basis for the exploratory data analysis phase.




