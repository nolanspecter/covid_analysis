SELECT * 
FROM Portfolio..vaccination
ORDER BY location, date;

SELECT * 
FROM Portfolio..infection_and_death
ORDER BY location, date;

-- Select columns of interset
SELECT location, date, population, total_cases, total_deaths
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL -- Remove continent figures
ORDER BY location, date;

-- Infection rate 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_rate
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Death rate 
SELECT location, date, population, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Countries with highest confirmed cases
SELECT location, MAX(total_cases) AS recent_total_cases
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY recent_total_cases DESC;

-- Top 10 Countries with highest infection rate
SELECT TOP 10 location, MAX(total_cases)/population * 100 AS infection_rate
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC;

-- Top 10 Countries with highest death rate over population
SELECT TOP 10 location, MAX(total_deaths)/population * 100 AS death_rate
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY death_rate DESC;

-- Top 10 Countries with highest death rate over confirmed cases
SELECT TOP 10 location, MAX(CONVERT(int, total_deaths))/MAX(total_cases) * 100 AS death_rate
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY death_rate DESC;

-- Continent figures
-- Continent case count
WITH continent_total_cases (continent, location, total_cases) AS
	(SELECT continent, location, MAX(total_cases) AS total_cases
	FROM Portfolio..infection_and_death
	WHERE continent IS NOT NULL
	GROUP BY continent, location)
SELECT continent, SUM(total_cases) AS continent_case_count
FROM continent_total_cases
GROUP BY continent
ORDER BY continent_case_count DESC;

-- Continent death count
WITH continent_total_death (continent, location, total_deaths) AS
	(SELECT continent, location, MAX(CAST(total_deaths AS int)) AS total_deaths
	FROM Portfolio..infection_and_death
	WHERE continent IS NOT NULL
	GROUP BY continent, location)
SELECT continent, SUM(total_deaths) AS continent_death_count
FROM continent_total_death
GROUP BY continent
ORDER BY continent_death_count DESC;

-- Continent death rate
WITH continent_total_death (continent, location, total_cases, total_deaths) AS
	(SELECT continent, location, MAX(total_cases) AS total_cases, MAX(CAST(total_deaths AS int)) AS total_deaths
	FROM Portfolio..infection_and_death
	WHERE continent IS NOT NULL
	GROUP BY continent, location)
SELECT continent, 
		SUM(total_cases) AS continent_total_cases, 
		SUM(total_deaths) AS continent_total_deaths, 
		SUM(total_deaths)/SUM(total_cases) * 100 AS continent_death_rate
FROM continent_total_death
GROUP BY continent
ORDER BY continent_death_rate DESC;

-- Global figures
SELECT date, 
		SUM(total_cases) AS global_case_count, 
		SUM(CAST(total_deaths AS int)) AS global_death_count, 
		SUM(CONVERT(int, total_deaths))/SUM(total_cases) * 100 AS global_death_rate
FROM Portfolio..infection_and_death
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;
