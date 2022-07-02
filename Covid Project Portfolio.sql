USE [Portfolio Project];

--SELECT * 
--FROM CovidDeaths$ 
--ORDER BY 3,4;

--SELECT * 
--FROM CovidVaccinations$ 
--ORDER BY 3,4;

--SELECT DATA IM GOING TO BE USING

SELECT location, date, total_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2;
 



--Looking at Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location LIKE '%states%' 
AND continent IS NOT NULL
ORDER BY 1,2;
 
 --Looking at Total Cases vs. Population
 --Shows what % of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentofpopulationwithcovid
FROM CovidDeaths$
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2;
 
 --Looking at Countries with Highest Infection Rate compared to Population
 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS percentofpopulationinfected
FROM CovidDeaths$
GROUP BY population,location
--WHERE location LIKE '%states%'
ORDER BY percentofpopulationinfected DESC;

--Showing Countries With Highest Death Count per Population
 
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Breaking things down by continent
--Showing continents with the highest death counts per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global Numbers

SELECT SUM(cast(new_deaths AS int)) AS total_deaths,SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathsPerCase
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total Population Vs. Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
ON	dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
ON	dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
ON	dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPopVaccinated
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
ON	dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated