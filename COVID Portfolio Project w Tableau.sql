/*
Queries used for Tableau Project
*/


-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'United States'
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2

-- Just a double check bASed off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths$
----WHERE location = 'United States'
--WHERE location = 'World'
----GROUP BY date
--ORDER BY 1,2


-- 2. 

-- We take these out AS they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent is null 
AND location NOT in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc


-- 3.

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- 4.


SELECT Location, Population,date, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc


--Original Queries 

SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4;

SELECT *
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4;

--SELECT the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2;

--Looking at Total cases vs. Total Deaths (Percentage of people who die who get infected)
--Shows the likelihood  of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'United States'
ORDER BY 1,2;

--Looking at Total cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location = 'United States'
ORDER BY 1,2;

--Countries with the highest infection rates compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

--Showing the coutries with highest death count per population

SELECT location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'United States'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

--Let's Break Things Down by Continent 

--Showing the Continents with the highest death per population
SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

--Global Numbers

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/ SUM (new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'United States'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3;

--	--USE CTE

WITH PopvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST (vac.new_vaccinations AS int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated 
FROM PopvsVAC
