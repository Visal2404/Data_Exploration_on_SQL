SELECT * 
FROM dbo.CovidDeaths
WHERE continent is not null;

Select Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent is not null
order by 1,2;

-- Looking at Total cases vs Total deaths
-- Calculate between total deaths and total cases to show the likly hood of contract the covid in each country
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

-- Looking at Total cases vs Population

Select Location, date, Population,total_cases, (total_cases / population) * 100 AS DeathPercentage
FROM dbo.CovidDeaths
Order by 1,2;

-- Looking at Countries with Highest Infection Rate

SELECT location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 AS 
PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY population, location
Order by HighestInfectionCount desc;

-- Showing Countries with Highest Death count
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null 
GROUP BY location
order by TotalDeathCount desc;

-- Break it down by continent on death count
select continent, Max(cast(total_deaths as int)) as Total_Death_Count
From dbo.CovidDeaths
where continent is not null
GROUP BY continent 
ORDER BY Total_Death_Count desc;

-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases) * 100 AS deathPercentage
FROM dbo.CovidDeaths
where continent is not null
--GROUP by date
Order by 1,2;

-- Total Population vs Vaccinaation

SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITIOn By dea.location order by dea.location, dea.date) AS RollingVaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHere dea.continent is not null
Order by 2,3;

-- CTE
With PopuvsVac (Continent, location, date, population, new_vaccinations, RollingVaccinations)
AS
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITIOn By dea.location order by dea.location, dea.date) AS RollingVaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT * , (RollingVaccinations/Population) * 100 FROM PopuvsVac;

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccination numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITIOn By dea.location order by dea.location, dea.date) AS RollingVaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Create View
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITIOn By dea.location order by dea.location, dea.date) AS RollingVaccinations
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null;

SELECT * from dbo.PercentPopulationVaccinated;

Create VIEW totalCasesVStotalDeath AS
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null;

CREATE VIEW highestDeathbyCountry AS
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null 
GROUP BY location;

Create VIEW deathbyContinent AS
select continent, Max(cast(total_deaths as int)) as Total_Death_Count
From dbo.CovidDeaths
where continent is not null
GROUP BY continent;