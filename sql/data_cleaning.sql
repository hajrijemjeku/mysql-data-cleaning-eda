 
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
  

   
 