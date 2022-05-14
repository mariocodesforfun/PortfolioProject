--Select * 
--from PortfolioProject..coviddeaths:


--Select * 
--from PortfolioProject..vaccinations;

--select the data we are going to be using 

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1, 2

-- total cases vs total deaths
-- shows the likelyhood of dying if you contract covid covid in your country 

select  Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
order by 1 , 2

-- Looking at the total cases vs the population 
-- Shows what percentage of population got COVID

select  location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
order by 1 , 2


-- Countries with the highest Infection Rate compared to Population

select  location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentPopulationInfected 
from PortfolioProject..coviddeaths
--where location like '%states%'
group by Location, Population
order by PercentPopulationInfected desc




select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--MAX((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT


select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--MAX((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- showing the continent with the highest  death count per population 

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--MAX((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is null
and location not like '%income%'
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS  

select SUM(NEW_CASES) as total_cases, SUM(cast (new_deaths as int)) as total_deaths,
SUM(cast (new_deaths as int))/SUM(NEW_CASES)*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
WHERE continent is not null
--group by date 
ORDER BY 1, 2 


-- looking at total population vs vacciantion 

select * 
from PortfolioProject..coviddeaths dea
join PortfolioProject..vaccinations vac
		on dea.location = vac.location 
		and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..vaccinations vac
		on dea.location = vac.location 
		and dea.date = vac.date
where dea.continent is not null
--and vac.location like '%albania%'
order by 2, 3 



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (bigint, new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date )
-- as RollingPeopleVaccinated, (RollingPeopleVaccinated/Population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..vaccinations vac
		on dea.location = vac.location 
		and dea.date = vac.date
where dea.continent is not null
order by 2, 3 

-- use CTE 


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/Population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..vaccinations vac
		on dea.location = vac.location 
		and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'Albania'
 
)

select*, ((RollingPeopleVaccinated/Population)*100) as vaccinationpercentage 
from PopvsVac


--TEMP TABLE 
--Drop table if exists #PERCENTPOPULATIONVACCINATED --if changes needed

CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)



INSERT INTO #PERCENTPOPULATIONVACCINATED

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/Population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..vaccinations vac
		on dea.location = vac.location 
		and dea.date = vac.date
where dea.continent is not null
--and dea.location = 'Albania'

select*, ((RollingPeopleVaccinated/Population)*100) as vaccinationpercentage 
from #PERCENTPOPULATIONVACCINATED





-- creating view to store data for later visualtion 

create view PERCENTPOPULATIONVACCINATED as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date )
as RollingPeopleVaccinated --(RollingPeopleVaccinated/Population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..vaccinations vac
		on dea.location = vac.location 
		and dea.date = vac.date
where dea.continent is not null
--order by 2, 3 

select * 
from PERCENTPOPULATIONVACCINATED