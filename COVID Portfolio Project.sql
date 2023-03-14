

--Covis 19 Data Exploration 

Select* 
From Project..CovidDeaths$
Where continent is not null
Order by 3, 4

Select* 
From Project..CovidVaccinations$
Order by 3, 4

--Select Data that we are going to using
Select location, date, total_cases, new_cases, total_deaths, population
From Project.. CovidDeaths$
Where continent is not null
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Show likleyhood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercantage
From Project.. CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

--Total Cases vs Population
--Shows likelihood of dying if you contract coivd in your country
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Project.. CovidDeaths$
--Where location like '%state%'
order by 1,2

--Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectedCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
From Project..CovidDeaths$
--Where like '%states%'
Group by location, population
order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project..CovidDeaths$
--Where location like '%state%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Project..CovidDeaths$
--Where location like '%state%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Project.. CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group by date
order by 1,2

--Total Population vs Vaccinations
--Shows Percentage of Population that recived at least one Covid Vaccine

Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccineted
--(RollingPeopleVaccineted/population)*100
From Project.. CovidDeaths$ dea
Join Project.. CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths$ dea
Join Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using Temp Table to perfom Calculation on Partition By in previous query
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths$ dea
Join Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths$ dea
Join Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select*
From PercentPopulationVaccinated