-- Query for Tableau Visualization

-- 1.
-- Time Series of Infection Rate 
Select location, population, date, total_cases AS case_count, (total_cases/population)* 100 AS infected_percent
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL
ORDER BY infected_percent DESC;


-- 2.
-- Latest Infection Rate by Countries
Select location, population, MAX(total_cases) AS latest_case_count, MAX(total_cases/population)* 100 AS infected_percent
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infected_percent DESC;


-- 3.
-- Total of Death by Continent
SELECT location, SUM(CAST(new_deaths AS int)) AS total_death_count
FROM Portfolio..infection_and_death
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
AND location NOT LIKE '%income'
GROUP BY location
ORDER BY total_death_count DESC;


-- 4.
-- Global Stat Summary
SELECT SUM(new_cases) AS total_cases, 
		SUM(CONVERT(int, new_deaths)) AS total_deaths, 
		SUM(CONVERT(int, new_deaths))/SUM(new_cases)*100 AS death_percent
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL;