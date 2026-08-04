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

CREATE TABLE `layoffs_drafting2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_drafting2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_drafting;

SELECT *
FROM layoffs_drafting2
WHERE row_num > 1;

DELETE
FROM layoffs_drafting2
WHERE row_num > 1;

SELECT *
FROM layoffs_drafting2;

-- Standardizing data

SELECT DISTINCT company ,TRIM(company)
FROM layoffs_drafting2;

UPDATE layoffs_drafting2
SET company =TRIM(company);

SELECT *
FROM layoffs_drafting2;

SELECT*
FROM layoffs_drafting2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_drafting2
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT country ,TRIM(TRAILING '.' FROM country)
FROM layoffs_drafting2
WHERE country LIKE 'United States%';

UPDATE layoffs_drafting2
SET  country=TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_drafting2;

UPDATE layoffs_drafting2
set `date`= STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_drafting2
MODIFY COLUMN `date` DATE;

-- Handling null values
UPDATE layoffs_drafting2
SET industry =NULL
WHERE industry ='';

SELECT *
FROM layoffs_drafting2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_drafting2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_drafting2
WHERE company = 'Airbnb';

SELECT ld2.industry,ld2_1.industry
FROM layoffs_drafting2 AS ld2
JOIN layoffs_drafting2 AS ld2_1
	ON ld2.company=ld2_1.company
    AND ld2.location=ld2_1.location
WHERE ld2.industry IS NULL 
AND ld2_1.industry IS  NOT NULL;

UPDATE layoffs_drafting2 AS ld2
JOIN layoffs_drafting2 AS ld2_1
	ON ld2.company=ld2_1.company
SET ld2.industry=ld2_1.industry
WHERE ld2.industry IS NULL
AND ld2_1.industry IS  NOT NULL;

SELECT *
FROM layoffs_drafting2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_drafting2;

-- Remove unecessary columns and rows
SELECT *
FROM layoffs_drafting2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_drafting2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_drafting2;

ALTER TABLE layoffs_drafting2
DROP COLUMN row_num;



