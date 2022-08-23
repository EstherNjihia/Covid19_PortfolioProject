
select *
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccination$
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

--Total cases vs Total Deaths
--Shows likelihood of covid death in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
from PortfolioProject..CovidDeaths$
WHERE location like '%africa%' and continent is not null
order by 1,2

--Total cases vs  Population
SELECT location, date,  population, total_cases,  (total_cases/population)* 100 AS PopulationPercentageCases
from PortfolioProject..CovidDeaths$
--WHERE location like '%africa%'
Where continent is not null
order by 1,2

-- Countries with the highest infection rate compared to population
SELECT location,   population, MAX(total_cases) AS HighestInfectionCount,  MAX(total_cases/population)* 100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--WHERE location like '%africa%'
Where continent is not null
GROUP BY location,   population 
order by PercentPopulationInfected DESC


--Countries with the highest death rate compared to population
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
from PortfolioProject..CovidDeaths$
--WHERE location like '%africa%'
Where continent is not null
GROUP BY location 
order by HighestDeathCount DESC

--Breaking into Continent
--showing continents with highest number of deaths
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
from PortfolioProject..CovidDeaths$
--WHERE location like '%africa%'
Where continent is  null
GROUP BY location 
order by HighestDeathCount DESC


SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
from PortfolioProject..CovidDeaths$
--WHERE location like '%africa%'
Where continent is not null
GROUP BY continent 
order by HighestDeathCount DESC
 

 --Global Numbers
 SELECT  SUM(new_cases) as total_new_cases, SUM(CAST(new_deaths as int)) as total_new_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases) as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--GROUP BY date
order by 1,2


--Total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 1,2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

----USE CTE
--With Popvsvac(Continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
--AS
--(
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--from PortfolioProject..CovidDeaths$ dea
--join PortfolioProject..CovidVaccination$ vac
--	on dea.location = vac.location
--	and dea.date =vac.date
--where dea.continent is not null

--)

--TEMP TABLE
DROP Table if exists  #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null


select * ,(RollingPeopleVaccinated/ population) * 100
from #PercentagePopulationVaccinated


--Creating view to store data for later visualization 
Create view PercentPopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
