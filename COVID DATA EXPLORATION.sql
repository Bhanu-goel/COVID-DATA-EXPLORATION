/*
COVID 19 DATA EXPLORATION

Skills used: Joins,
		     CTE's,
			 Temp Tables,
			 Windows Functions,
			 Aggregate Functions,
			 Creating Views,
			 Converting Data Types
*/

USE [COVID DATA EXPLORATION]

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4;

-- SELECT DATA THAT WE ARE GOING TO STARTING WITH
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- LOOKING FOR TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF CONTACT WITH COVID IN YOUR COUNTRY
SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 AS [DEATH PERCENTAGE(%)]
FROM CovidDeaths
WHERE location like '%India%'
AND continent IS NOT NULL
ORDER BY 1,2;


-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT location,date,population,total_cases,(total_cases/population)*100 AS [AREA COVERED BY COVID PERCENTAGE(%)]
FROM CovidDeaths
WHERE location like '%India%'
AND continent IS NOT NULL
ORDER BY 1,2;


-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location,population,MAX(total_cases) AS [HIGHEST INFECTION COUNT],MAX((total_cases/population))*100 AS [PERCENT POPULATION INFECTED(%)]
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY [PERCENT POPULATION INFECTED(%)] DESC;


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location,MAX(CAST(total_deaths AS INT)) AS [TOTAL DEATH COUNT]
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY [TOTAL DEATH COUNT] DESC;


-- LET'S BREAK DOWN THINGS BY CONTINENT
-- SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION
SELECT continent,MAX(CAST(total_deaths AS INT)) AS [TOTAL DEATH COUNT]
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY [TOTAL DEATH COUNT] DESC;


--  GLOBAL NUMBERS
SELECT SUM(new_cases) AS [TOTAL CASES],SUM(CAST(new_deaths AS INT)) AS [TOTAL DEATHS],
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS [DEATH PERCENTAGE(%)]
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) AS [ROLLING PEOPLE VACCINATED]
--([ROLLING PEOPLE VACCINATED]/CD.population)*100 AS [VACCINATION PER POPULATION(%)]
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2,3;


-- Using CTE to perform Calculation on Partition By in previous query
WITH POPSVSVAC (CONTINENT,LOCATION,DATE,POPULATION,[NEW VACCINATION],[ROLLING PEOPLE VACCINATED])
AS
(
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) AS [ROLLING PEOPLE VACCINATED]
--([ROLLING PEOPLE VACCINATED]/CD.population)*100 AS [VACCINATION PER POPULATION(%)]
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
--ORDER BY 2,3;
)
SELECT *,([ROLLING PEOPLE VACCINATED]/POPULATION)*100 AS [NUMBER OF PEOPLE VACCINATED(%)] 
FROM POPSVSVAC;


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC,
[NEW VACCINATION] NUMERIC,
[ROLLING PEOPLE VACCINATED] NUMERIC
)

INSERT INTO #PERCENTPOPULATIONVACCINATED
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) AS [ROLLING PEOPLE VACCINATED]
--([ROLLING PEOPLE VACCINATED]/CD.population)*100 AS [VACCINATION PER POPULATION(%)]
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
--ORDER BY 2,3;

Select *, ([ROLLING PEOPLE VACCINATED]/Population)*100 AS [NUMBER OF PEOPLE VACCINATED(%)]
From #PercentPopulationVaccinated


-- CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW [PERCENT POPULATION VACCINATED] AS
SELECT CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations,
SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) AS [ROLLING PEOPLE VACCINATED]
--([ROLLING PEOPLE VACCINATED]/CD.population)*100 AS [VACCINATION PER POPULATION(%)]
FROM CovidDeaths CD
JOIN CovidVaccinations CV
ON CD.location = CV.location
AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
--ORDER BY 2,3;

SELECT * FROM [PERCENT POPULATION VACCINATED];
