select * from PortfolioProject..CovidDeaths$
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths$
order by 1,2;


--Looking at the total cases vs Total deaths
--shows liklihood of dying if you contract covid inn you country
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathCount
from PortfolioProject.. CovidDeaths$
where location like '%states%' 
order by 1,2;

--Looking at the total cases vs population
--shows what percentage of population got covid
 select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject.. CovidDeaths$
--where location like '%states%' 
where location is not null
order by 1,2;

-- Looking at countries with highest Infection rate compared to population
select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject.. CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location, population
order by PercentagePopulationInfected desc;


-- showig countries woth highest death count per population
select location, max(cast(total_deaths as int)) as  TotalDeathCount
from PortfolioProject.. CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc;
 

 -- LET'S BREAK THINGS DOWN BY CONTINENT

  --Showing continents with the highest  death count per population
  
select continent, max(cast(total_deaths as int)) as  TotalDeathCount
from PortfolioProject.. CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc;


--GlOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from PortfolioProject.. CovidDeaths$
--where location like '%states%' 
where continent is not null
--group by date
order by 1,2;

--Looking at Total Population vs vacination


--USE CTE
with popvsVac (continent, location, Date, population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, 
dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject.. CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)

select *, (RollingPeopleVaccinated/population)*100
from popvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationvaccinated
create Table #PercentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into  #PercentPopulationvaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, 
dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject.. CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationvaccinated


-- creating view to store data for later visualization

create view PercentPopulationvaccinated as 
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, 
dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject.. CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 