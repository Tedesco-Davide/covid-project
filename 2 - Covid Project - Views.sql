-- 1 -- Showing the sum of the Total Global Deaths

DROP VIEW IF EXISTS TotalGlobalDeathsSum_VIEW

USE CovidProject
GO
CREATE VIEW TotalGlobalDeathsSum_VIEW AS
SELECT SUM(new_cases) AS total_global_cases,
	   SUM(CAST(new_deaths AS INT)) AS total_global_deaths,
	   SUM(CAST(new_deaths AS INT))*100/SUM(new_cases) AS global_death_percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GO

-- 2 -- Showing Continents with Highest Death count

DROP VIEW IF EXISTS HighestDeathCountContinents_VIEW

USE CovidProject
GO
CREATE VIEW HighestDeathCountContinents_VIEW AS
SELECT continent, 
	   SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
GO

-- 3 -- Looking at Countries with Highest Infection Rate compared to Population

DROP VIEW IF EXISTS HighestInfectionRate_VIEW

USE CovidProject
GO
CREATE VIEW HighestInfectionRate_VIEW AS
SELECT location, 
	   population, 
	   highest_infection_count, 
	   infection_rate
FROM CovidProject..HighestInfectionRate_TABLE
GROUP BY location, population, highest_infection_count, infection_rate
GO

-- 4 -- Looking at Countries with Highest Infection Rate compared to Population, with dates

DROP VIEW IF EXISTS HighestInfectionRateDate_VIEW

USE CovidProject
GO
CREATE VIEW HighestInfectionRateDate_VIEW AS
SELECT location, 
	   population, 
	   date,
	   highest_infection_count, 
	   infection_rate
FROM CovidProject..HighestInfectionRateDate_TABLE
GROUP BY location, population, date, highest_infection_count, infection_rate