SELECT * 
FROM Projectportfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

-- SELECT * 
-- FROM Projectportfolio..Covidvaccinations
-- ORDER BY 3,4;

--Covid death percentage in India.

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Projectportfolio..CovidDeaths
WHERE location LIKE '%india%'
ORDER BY 1,2; 
--
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM Projectportfolio..CovidDeaths
--WHERE location LIKE '%india%'
ORDER BY 1,2; 

--Looking at countries with highest infection rate
SELECT location, population, MAX(total_cases) AS Highestinfectioncount, MAX((total_cases/population))*100 AS Percentpopulationinfected
FROM Projectportfolio..CovidDeaths
--WHERE location LIKE '%india%'
GROUP BY LOCATION, POPULATION
ORDER BY Percentpopulationinfected desc;

--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Projectportfolio..CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent is not null
GROUP BY LOCATION
ORDER BY TotalDeathCount desc;

-- showing continents with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Projectportfolio..CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Global Numbers
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS int)) AS Total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM Projectportfolio..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- Total Global Number
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS int)) AS Total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM Projectportfolio..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


-- All the Vaccination Information

SELECT * 
FROM Projectportfolio..Covidvaccinations

--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated 
FROM Projectportfolio..CovidDeaths dea
JOIN Projectportfolio..Covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Projectportfolio..CovidDeaths dea
JOIN Projectportfolio..Covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3;
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

--Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Projectportfolio..CovidDeaths dea
JOIN Projectportfolio..Covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;


-- Creating view to store data for later visualisation

create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM Projectportfolio..CovidDeaths dea
JOIN Projectportfolio..Covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3;

SELECT *
FROM PercentPopulationVaccinated