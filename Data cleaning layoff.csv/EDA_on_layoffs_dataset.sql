-- EDA
SELECT *
FROM layoffs_drafting2;

SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoffs_drafting2;

SELECT *
FROM layoffs_drafting2
WHERE percentage_laid_off =1
ORDER BY funds_raised_millions DESC
;

SELECT company,SUM(total_laid_off)
FROM layoffs_drafting2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`),MAX(`date`)
FROM layoffs_drafting2;


SELECT industry,SUM(total_laid_off)
FROM layoffs_drafting2
GROUP BY industry
ORDER BY 2 DESC;


SELECT country,SUM(total_laid_off)
FROM layoffs_drafting2
GROUP BY country
ORDER BY 2 DESC;


SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoffs_drafting2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage,SUM(total_laid_off)
FROM layoffs_drafting2
GROUP BY stage
ORDER BY 2 DESC;


