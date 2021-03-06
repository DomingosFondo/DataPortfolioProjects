Select *
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
where total_deaths is not null
order by 1,2

Select people_fully_vaccinated, date, location, aged_65_older
from [Portfolio Project]..CovidVaccinations
where people_fully_vaccinated is not NULL
order by location

-- Looking at Totl cases vs Total Deaths
-- Probability of contracting the virus resulting in Death
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location ='Mozambique'
order by 1,2

--Looking at Total Cases vs Population
--Examining how much of the population is getting infected
Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From [Portfolio Project]..CovidDeaths
--Where location ='Mozambique'
order by 1,2

--Looking at countries with highest Infectiojn rate compared to Population.

Select location, population, MAX(total_cases) as Highest, MAX((total_cases/population))*100 as HighestPercentage
From [Portfolio Project]..CovidDeaths
--Where location ='Mozambique'
Group by location, population
order by HighestPercentage desc


--Analyzing the Total Death count by continent

--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From [Portfolio Project]..CovidDeaths
----Where location ='Mozambique'
--where continent is null
--Group by location
--order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location ='Mozambique'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location ='Mozambique'
where continent is not null
Group by location
order by TotalDeathCount desc

--Global Statistics

Select date, SUM((new_cases)) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
order by 1,2

Select SUM((new_cases)) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visulaization

Create View Percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Create View HighestInfection AS
Select location, population, MAX(total_cases) as Highest, MAX((total_cases/population))*100 as HighestPercentage
From [Portfolio Project]..CovidDeaths
Where location ='Mozambique'
Group by location, population
--order by HighestPercentage desc