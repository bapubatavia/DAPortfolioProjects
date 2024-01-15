--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

SELECT *
FROM PortfolioProject..CovidDeaths
Order by 1,2

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


-- Looking at Total Cases vs the Population
-- Shows what % of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage 
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
	PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc


-- Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths WHERE continent is not null
Group by location
Order by HighestDeathCount desc



-- Let's break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths WHERE continent is not null
Group by continent
Order by HighestDeathCount desc



-- Showing the continents with highest death counts per population (Correct one)

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount, population, MAX((total_deaths/population))*100 as DeathPerPopPercentage
FROM PortfolioProject..CovidDeaths
WHERE location <> 'international' AND continent is null 
Group by location, population
Order by DeathPerPopPercentage desc

-- Showing the continents with highest death counts per population (Tutorial one)

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
Group by continent
Order by HighestDeathCount desc


-- GLOBAL Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(New_deaths as int))/SUM(new_cases))*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Group by date
Order by 1,2


-- Looking at total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumVaccinesPerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order by 2, 3

-- USING CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, SumVaccinesPerDay)
as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumVaccinesPerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2, 3
)
SELECT *, (SumVaccinesPerDay/Population)*100
FROM PopvsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, SumVaccinesPerDay numeric) 

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumVaccinesPerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--Order by 2, 3

SELECT *, (SumVaccinesPerDay/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumVaccinesPerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2, 3


-- Creating view for death count per continent

CREATE VIEW ContinentDeathCount as
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
Group by continent
--Order by HighestDeathCount desc