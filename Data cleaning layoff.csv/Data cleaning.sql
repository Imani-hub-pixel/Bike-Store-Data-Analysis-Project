-- Data cleaning

SELECT *
FROM layoffs;
-- 1.Remove duplicates
-- 2.Standardize the data(spelling etc)
-- 3.Handle null values
-- 4.Remove unecessary columns and rows

-- Working on a copy of the raw data so that incase there is a mistake we can rectify easily
CREATE TABLE layoffs_drafting
LIKE layoffs;

SELECT *
FROM layoffs_drafting;

INSERT layoffs_drafting
SELECT *
FROM layoffs;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_drafting
)
SELECT*
FROM duplicate_cte
WHERE row_num >1;
