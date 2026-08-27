-- Exploratory Data Analysis
-- Here we are just going to explore the data and find trends or patterns or anything interesting like outliers.
-- Normally when you start the EDA process you have some idea of what you're looking for, with this info we are just going to look around and see what we find!

select distinct total_laid_off from layoffs_staging2 
order by 1 desc;

 -- What is the largest number of employees laid off in a single record and what is the largest percentage of a workforce laid off in a single record?
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

select * from layoffs_staging2 
where percentage_laid_off = 1.0; -- all the information about those companies who laid off 100% of its workforce

select * from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised desc; -- see how big some of these companies were

select company, sum(total_laid_off) from layoffs_staging2
group by company
order by 2 desc; -- check which companies had the highest total number of layoffs

select min(date), max(date)
from layoffs_staging2; -- time range of the dataset.

select industry, sum(total_laid_off) from layoffs_staging2
group by industry
order by 2 desc; -- check which industries had the highest total number of layoffs

select country, sum(total_laid_off) from layoffs_staging2
group by country
order by 2 desc; -- check which countries had the highest total number of layoffs

select year(date) , sum(total_laid_off)
from layoffs_staging2
group by year(date)
order by 1 desc; -- check how many total layoffs were recorded in each year

select stage , sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc; -- check how many total layoffs were recorded for each stage

select substring(date, 1, 7) as month, sum(total_laid_off)
from layoffs_staging2
where substring(date, 1, 7) is not null
group by month
order by 1 asc; -- check the total number of layoffs recorded per month


with monthly_layoffs as 
(
select substring(date, 1, 7) as month, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(date, 1, 7) is not null
group by month
order by 1 asc
)
select month, total_off, sum(total_off) over(order by month) as monthly_layoffs
from monthly_layoffs; -- check monthly rolling total 


with yearly_layoffs as 
(
select substring(date, 1, 4) as year, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(date, 1, 4) is not null
group by year
order by 1 asc
)
select year, total_off, sum(total_off) over(order by year) as yearly_layoffs
from yearly_layoffs; -- check yearly rolling total

with company_layoffs as 
(
select company, substring(date, 1, 4) as year, sum(total_laid_off) as total_off 
from layoffs_staging2
where date is not null 
group by company, year
order by 1 asc
)
select company, year, total_off, sum(total_off) over (partition by company order by year) as yearly_company_offs
from company_layoffs 
order by company, year; -- check company/year rolling total


with company_year (company, years, total_laid_off) as 
(
select company, substring(date, 1, 4) as year, sum(total_laid_off) as total_off 
from layoffs_staging2
where date is not null 
group by company, year
), company_year_rank as 
(
select *, 
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
)
select * from company_year_rank
where ranking <= 5;  -- check top 5 companies with most laid off per year
