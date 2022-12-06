SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--Select the data that we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at the Total Cases vs Population

SELECT Location, date, total_cases, Population, (total_cases/Population)*100 AS Infected_Rate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
--WHERE Location like '%states%' 
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Max(total_cases) AS Highest_Infection_Count, Population, Max((total_cases/Population))*100 AS Percent_Population_Infected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
GROUP BY Location, population
ORDER BY Percent_Population_Infected DESC

--Showing Countries with Highest Death Count per Population 

SELECT location, Max(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC

--Let's break things down by continent

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths	
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int)))/Sum(new_cases)*100 AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE Location like '%states%'
Where continent is not null
GROUP BY date
ORDER BY 1,2

--Look at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Accumulated_Vaccinations
, --(Accumulated_Vaccinations/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 



-- USE CTE

WITH PopsvsVac(Continent, Location, Date, Population, new_vaccinations, Accumulated_Vaccinations)
as
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Accumulated_Vaccinations
 --,(Accumulated_Vaccinations/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
)
SELECT *, (Accumulated_Vaccinations/population)*100 AS Accumulated_Vaccinations_Percentage
FROM PopsvsVac

--Temp Table 

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime, 
Population numeric, 
new_vaccinations numeric,
Accumulated_Vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Accumulated_Vaccinations
 --,(Accumulated_Vaccinations/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (Accumulated_Vaccinations/population)*100 AS Accumulated_Vaccinations_Percentage
FROM #PercentPopulationVaccinated


--Creating a View to store data for later visualizations

Create View PercentPopulationVaccinated AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Accumulated_Vaccinations
 --,(Accumulated_Vaccinations/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated







