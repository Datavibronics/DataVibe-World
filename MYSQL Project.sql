SELECT *
 FROM layoffs;
 
 CREATE table layoffs_staging
 LIKE layoffs;
 
 SELECT *
 FROM layoffs_staging;
 
 INSERT layoffs_staging
 SELECT*
 FROM layoffs;
 
 WITH duplicate_cte AS
 (
 SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
 FROM layoffs_staging
 )
 SELECT*
 FROM duplicate_cte
 WHERE row_num >1 ;
 
 
 CREATE TABLE `layoffs_staging2` (
`company` text,
`location` text,
`industry` text,
`total_laid_off` int DEFAULT NULL,
`percentage_laid_off` text,
`date` text,
`stage` text,
`country` text,
`funds_raised_millions` int DEFAULT NULL,
`row_num` 	INT
)ENGINE=InnoDB DEFAULT CHARSET=	utf8mb4 COLLATE= utf8mb4_bg_0900_ai_ci;
 

SELECT*
FROM layoffs_staging2;
 
INSERT INTO layoffs_staging2
 SELECT *,
 ROW_NUMBER () OVER (
 PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
 FROM layoffs_staging;
 
 DELETE 
FROM layoffs_staging2
WHERE row_num>1;

SELECT  trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company=trim(company);

SELECT distinct industry
FROM layoffs_staging2
;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT trim(TRAILING ' ' FROM country) 
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = trim(TRAILING ' ' FROM country) 
WHERE country LIKE 'United states%';

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`= STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry =' '
;

SELECT*
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;


ALTER TABLE layoffs_staging2
DROP row_num;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

SELECT company ,sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT max(`date`),min(`date`)
FROM layoffs_staging2;

SELECT industry ,sum(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country ,sum(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT `date` ,sum(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;

SELECT YEAR (`date`) ,sum(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR (`date`)
ORDER BY 1 DESC;

SELECT stage ,sum(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT substring(`date`,1,7) AS months,sum(total_laid_off) 
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY months
ORDER BY 1 ASC;

WITH rolling_total AS
(
SELECT substring(`date`,1,7) AS months,sum(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY months
ORDER BY 1 ASC
)
SELECT months,total_off,
sum(total_off)OVER (ORDER BY months) AS rolling_total
FROM rolling_total;

SELECT company ,sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company ,YEAR(`date`),sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC;

WITH company_year (Company,years,total_laid_off)  AS
(
SELECT company ,YEAR(`date`),sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
),  company_year_ranking AS
(
SELECT*, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years is not null
)
SELECT *
FROM company_year_ranking
WHERE ranking<=5;

SELECT company,
       SUM(total_laid_off) AS layoffs,
       MAX(funds_raised_millions) AS funding
FROM layoffs_staging2
GROUP BY company
HAVING funding IS NOT NULL
AND layoffs IS NOT NULL
ORDER BY funding DESC;

SELECT industry,
       AVG(total_laid_off) AS avg_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY avg_layoffs DESC;

SELECT company,
       COUNT(*) AS layoff_events
FROM layoffs_staging2
GROUP BY company
ORDER BY layoff_events DESC;

SELECT country, industry, SUM(total_laid_off) AS layoffs
FROM layoffs_staging2
GROUP BY country, industry
ORDER BY layoffs DESC;

SELECT
 CASE
   WHEN YEAR(`date`) < 2022 THEN 'Pre-2022'
   ELSE '2022+'
 END AS period,
 SUM(total_laid_off) AS layoffs
FROM layoffs_staging2
GROUP BY period;


















