SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2;

--Comparing the Total Cases vs Total Deaths
--Show percentage of death that has Covid cases
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--location can specify which place to look
WHERE location like '%states%'
ORDER BY 1,2;   

--Comparing the Total Cases vs Population
--Show percentage of population that has Covid cases
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject..CovidDeaths$
--location can specify which place to look
WHERE location like '%states%'
ORDER BY 1,2;   

--Comparing countries with Highest Infection Rate to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationPercentage
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY PopulationPercentage DESC;   

--Comparing countries with Highest Death Count per Population
SELECT location, population, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC;   

--Comparing countries with Highest Death Count per Population
SELECT location, population, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC;   

--Comparing Death Count to Continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC; 

--Comparing continent with Highest Death Count per population
SELECT continent, population, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY TotalDeathCount DESC; 

--Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Comparing the Total Population vs Vaccinations
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(int, vaccine.new_vaccinations)) OVER 
(Partition by death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(int, vaccine.new_vaccinations)) OVER 
(Partition by death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageRollingPeopleVaccinated_per_Population
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(int, vaccine.new_vaccinations)) OVER 
(Partition by death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageRollingPeopleVaccinated_per_Population
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualization
DROP View if exists PercentPopulationVaccinated
CREATE View PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
SUM(CONVERT(int, vaccine.new_vaccinations)) OVER 
(Partition by death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVaccinations$ vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
