-- Exploring the Covid Deaths data set
SELECT *
FROM CovidProject..CovidDeaths
ORDER BY 3,4
-- Exploring the Covid Vaccinations data set
SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3,4


-- Select Data that we are going to be using

SELECT location, 
	   date, 
	   total_cases, 
	   new_cases, 
	   total_deaths, 
	   population
FROM CovidProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in Italy

SELECT location, 
	   date, 
	   total_cases, 
	   total_deaths, 
	   (total_deaths/total_cases)*100 AS death_percentage
FROM CovidProject..CovidDeaths
WHERE location = 'Italy'
ORDER BY death_percentage DESC


-- Looking at Total Cases vs Population
-- Shows what percentage of population has got tested and infection confirmed by Covid, by countries

SELECT location, 
	   date,
	   population, 
	   total_cases, 
	   (total_cases/population)*100 AS infected_percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 DESC


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, 
	   population, 
	   MAX(total_cases) as highest_infection_count, 
	   MAX((total_cases/population))*100 AS infection_rate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC


-- Looking at Countries with Highest Infection Rate compared to Population, with dates

SELECT location, 
	   population, 
	   date,
	   MAX(total_cases) as highest_infection_count, 
	   MAX((total_cases/population))*100 AS infection_rate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY infection_rate DESC


-- Showing Countries with Highest Death count

SELECT location, 
	   SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


-- Showing Continents with Highest Death count, for visualization purpose

SELECT continent, 
	   SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


-- Showing a Global View on the Highest Death count, for a more accurate view

SELECT location, 
	   SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM CovidProject..CovidDeaths AS cd
WHERE
(
	cd.continent IS NULL
	AND location NOT LIKE '%income%' 
)
GROUP BY location
ORDER BY total_death_count DESC


-- Showing a Global View on the Highest Death count, based on incomes

SELECT location, 
	   SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE location LIKE '%income%' 
GROUP BY location
ORDER BY total_death_count DESC


-- Showing the Total Global Deaths, by date

SELECT date, 
	   SUM(new_cases) AS total_global_cases,
	   SUM(CAST(new_deaths AS INT)) AS total_global_deaths,
	   SUM(CAST(new_deaths AS INT))*100/SUM(new_cases) AS global_death_percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date DESC


-- Showing the sum of the Total Global Deaths

SELECT SUM(new_cases) AS total_global_cases,
	   SUM(CAST(new_deaths AS INT)) AS total_global_deaths,
	   SUM(CAST(new_deaths AS INT))*100/SUM(new_cases) AS global_death_percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL


-- Using a CTE to look at percentage of Total Vaccinated vs Population, in each country, worldwide

WITH PopulationVsVaccinations_Total (continent, location, population, total_people_vaccinated)
AS 
(
	SELECT dea.continent, 
		   dea.location,
		   dea.population,
		   MAX(CAST(vac.people_vaccinated AS BIGINT)) AS total_people_vaccinated
	FROM CovidProject..CovidDeaths AS dea
	INNER JOIN CovidProject..CovidVaccinations AS vac
		ON dea.location = vac.location
	WHERE dea.continent IS NOT NULL 
	GROUP BY dea.continent, dea.location, dea.population
)
SELECT *, (total_people_vaccinated/population)*100 AS total_people_vaccinated_percentage
FROM PopulationVsVaccinations_Total
ORDER BY 5 DESC


-- Using a Table to look at percentage of Vaccinated Population, in each country, worldwide; adding up by day

DROP TABLE IF EXISTS PopulationVsVaccination_Rolling_TABLE

USE CovidProject
CREATE TABLE PopulationVsVaccination_Rolling_TABLE (
	continent NVARCHAR(255), 
	location NVARCHAR(255),
	date DATETIME,
	population NUMERIC, 
	new_vaccinations NUMERIC, 
	rolling_people_vaccinated NUMERIC
)
INSERT INTO PopulationVsVaccination_Rolling_TABLE (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population,
	   CAST(vac.new_vaccinations AS INT) AS new_vaccinations,
	   SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM CovidProject..CovidDeaths AS dea
INNER JOIN CovidProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100 AS	rolling_people_vaccinated_percentage
FROM PopulationVsVaccination_Rolling_TABLE
ORDER BY 2,3


--------------------- New Tables created for Visualization purposes ---------------------

DROP TABLE IF EXISTS HighestInfectionRate_TABLE

USE CovidProject
CREATE TABLE HighestInfectionRate_TABLE (
	location NVARCHAR(255),
	population NUMERIC, 
	highest_infection_count NUMERIC, 
	infection_rate NUMERIC
)
INSERT INTO HighestInfectionRate_TABLE (location, population, highest_infection_count, infection_rate)
SELECT location, 
	   population, 
	   MAX(total_cases) AS highest_infection_count, 
	   MAX((total_cases/population))*100 AS infection_rate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC

UPDATE HighestInfectionRate_TABLE
SET highest_infection_count = 0, infection_rate = 0
WHERE highest_infection_count IS NULL OR infection_rate IS NULL

--- Checking that actual NULLs are overridden with 0s

SELECT * 
FROM HighestInfectionRate_TABLE
ORDER BY infection_rate DESC

---------------------

DROP TABLE IF EXISTS HighestInfectionRateDate_TABLE

USE CovidProject
CREATE TABLE HighestInfectionRateDate_TABLE (
	location NVARCHAR(255),
	population NUMERIC, 
	date DATETIME,
	highest_infection_count NUMERIC, 
	infection_rate NUMERIC
)
INSERT INTO HighestInfectionRateDate_TABLE (location, population, date, highest_infection_count, infection_rate)
SELECT location, 
	   population, 
	   date,
	   MAX(total_cases) AS highest_infection_count, 
	   MAX((total_cases/population))*100 AS infection_rate
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY infection_rate DESC

UPDATE HighestInfectionRateDate_TABLE
SET highest_infection_count = 0, infection_rate = 0
WHERE highest_infection_count IS NULL OR infection_rate IS NULL

--- Checking that actual NULLs are overridden with 0s

SELECT * 
FROM HighestInfectionRateDate_TABLE
ORDER BY infection_rate DESC

-----------------------------------------------------------------------------------------