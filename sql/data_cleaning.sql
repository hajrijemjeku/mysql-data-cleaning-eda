 
 create table layoffs_staging like layoffs;
 
 insert into layoffs_staging select * from layoffs;
 
 
 -- remove duplicates; 
 select *, row_number() over
 (partition by company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country)
 as row_num
 from layoffs_staging;
 
 with duplicate_cte as (
  select *, row_number() over
 (partition by company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country)
 as row_num
 from layoffs_staging
 )
 select * 
 from duplicate_cte where  row_num > 1;
 
 
 CREATE TABLE layoffs_staging2 AS
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY
               company,
               location,
               total_laid_off,
               `date`,
               percentage_laid_off,
               industry,
               stage,
               funds_raised,
               country
       ) AS row_num
FROM layoffs_staging;

delete from layoffs_staging2 where row_num > 1;

-- Standardizing data;

select company, trim(company) as trimmed_company
from layoffs_staging2
where company <> trim(company); -- returned 16 rows containing leading or trailing spaces

update layoffs_staging2
set company = trim(company); -- table updated - spaces removed

select distinct industry from layoffs_staging2 order by 1; -- checked industry values for inconsistencies

select distinct country from layoffs_staging2 order by 1;
select * from layoffs_staging2 where country = 'UAE' or country like '%Emir%';
update layoffs_staging2 set country = 'United Arab Emirates' where country = 'UAE'; 

 
 select distinct stage from layoffs_staging2 order by 1; -- nothing to change here
 
 select distinct date, str_to_date(date, '%m/%d/%Y') from layoffs_staging2 order by 1;
 update layoffs_staging2 set date = str_to_date(date, '%m/%d/%Y'); -- converted the text value to a DATE value
 
 select distinct date from layoffs_staging2 where `date` = '' or `date` is null order by 1;
 
 alter table layoffs_staging2 modify column date date; -- changed datatype from text to date
 
 
 -- null values
 
 select * from layoffs_staging2 where industry is null or industry = '';
 select * from layoffs_staging2 where company = 'Appsmith' or company = 'Eyeo';
 
 select t1.industry, t1.location, t2.industry, t2.location from layoffs_staging2 t1
 join layoffs_staging2 t2 on t1.company = t2.company and t1.location = t2.location  
 where (t1.industry is null or t1.industry = '')
 and t2.industry is not null; -- checked whether missing industry values could be populated from matching company/location records; no reliable values found
 
 alter table layoffs_staging2 drop column row_num; -- dropped unnecessary column
 
select * from layoffs_staging2
where ( total_laid_off is null or total_laid_off = '')
and (percentage_laid_off is null or percentage_laid_off = '');


delete from layoffs_staging2
where (total_laid_off is null or total_laid_off = '')
and (percentage_laid_off is null or percentage_laid_off = ''); -- deleted rows where both total_laid_off and percentage_laid_off were blank
  
select count(*) as remaining_missing_layoff_records from layoffs_staging2
where (total_laid_off is null or total_laid_off = '')
and (percentage_laid_off is null or percentage_laid_off = ''); -- verify that those rows with blank values are gone
  
  
-- Converting total_laid_off from text to integer;

update layoffs_staging2
set total_laid_off = null
where total_laid_off = ''; -- converted empty strings to NULL before changing the datatype

alter table layoffs_staging2
modify column total_laid_off int; -- changed datatype from text to INT


-- Converting funds_raised from text to decimal;

select distinct funds_raised
from layoffs_staging2
order by 1; -- checked values to determine the appropriate numeric datatype

select count(*)
from layoffs_staging2
where funds_raised = ''; -- checked for empty strings

update layoffs_staging2
set funds_raised = null
where funds_raised = ''; -- converted empty strings to NULL before changing the datatype

alter table layoffs_staging2
modify column funds_raised decimal(10,4); -- changed datatype from text to DECIMAL to preserve decimal values