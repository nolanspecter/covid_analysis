SELECT * 
FROM Portfolio..vaccination V
ORDER BY location, date;

--Rolling count total vaccination
SELECT V.continent, 
		V.location, 
		V.date, 
		D.population, 
		V.new_vaccinations,
		SUM(CAST(V.new_vaccinations AS bigint)) OVER (PARTITION BY V.location ORDER BY V.location, V.date) AS total_vaccinations
FROM Portfolio..vaccination AS V
JOIN Portfolio..infection_and_death AS D
ON V.continent = D.continent
AND V.location = D.location
AND V.date = D.date
WHERE V.continent IS NOT NULL
ORDER BY V.location, V.date;

-- Percent vaccinated by countries
WITH vac_percent (continent, location, date, population, new_vaccinations, total_vaccinations) AS  
(SELECT V.continent, 
		V.location, 
		V.date, 
		D.population, 
		V.new_vaccinations,
		SUM(CAST(V.new_vaccinations AS bigint)) OVER (PARTITION BY V.location ORDER BY V.location, V.date) AS total_vaccinations
FROM Portfolio..vaccination AS V
JOIN Portfolio..infection_and_death AS D
ON V.continent = D.continent
AND V.location = D.location
AND V.date = D.date
WHERE V.continent IS NOT NULL)
SELECT continent, location, population, total_vaccinations, total_vaccinations / population * 100 AS percent_vaccinated
FROM vac_percent
ORDER BY location;

-- Using Temp Table
DROP TABLE IF EXISTS #PercentDeathVSPercentVac
CREATE TABLE #PercentDeathVSPercentVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
total_cases numeric,
total_deaths numeric,
total_vaccinations numeric,
)

INSERT INTO #PercentDeathVSPercentVac
SELECT V.continent, 
		V.location, 
		V.date, 
		D.population, 
		D.total_cases,
		D.total_deaths,
		SUM(CAST(V.new_vaccinations AS bigint)) OVER (PARTITION BY V.location ORDER BY V.location, V.date) AS total_vaccinations
FROM Portfolio..vaccination AS V
JOIN Portfolio..infection_and_death AS D
ON V.continent = D.continent
AND V.location = D.location
AND V.date = D.date
WHERE V.continent IS NOT NULL;

SELECT *, 
		total_deaths/total_cases * 100 AS death_percentage,
		total_vaccinations/population * 100 AS vaccinations_percentage
FROM #PercentDeathVSPercentVac;

-- Create Views
CREATE VIEW CountPopulationVaccinated AS 
SELECT V.continent, 
		V.location, 
		V.date, 
		D.population, 
		V.new_vaccinations,
		SUM(CAST(V.new_vaccinations AS bigint)) OVER (PARTITION BY V.location ORDER BY V.location, V.date) AS total_vaccinations
FROM Portfolio..vaccination AS V
JOIN Portfolio..infection_and_death AS D
ON V.continent = D.continent
AND V.location = D.location
AND V.date = D.date
WHERE V.continent IS NOT NULL;
