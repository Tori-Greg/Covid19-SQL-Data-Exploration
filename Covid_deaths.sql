SELECT * FROM Portfolio_Projects..Coviddeaths
order by 3,4

--SELECT * FROM Portfolio_Projects..CovidVaccinations
--order by 3,4

--SELECT preferred data

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Portfolio_Projects..Coviddeaths
order by 1,2

-- Examining total deaths vs total cases 
-- Shows likelihood of dying in your country
SELECT location, date, total_cases, total_deaths, (convert(float,total_deaths)/convert(float,total_cases)) * 100 as Deathpercentage
FROM Portfolio_Projects..Coviddeaths
where location like '%states%'
order by 1,2

-- Examining total cases to population
-- Shows percentage of population who contacted covid
SELECT location, date, total_cases, Population, (convert(float,total_cases)/(population)) * 100 as Percentageofpopulationinfected
FROM Portfolio_Projects..Coviddeaths
--where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rates compared to population
SELECT location, Population, MAX(total_cases) as Highestinfectioncount, Max(cast(total_cases as int)/population) * 100 as Percentageofpopulationinfected
FROM Portfolio_Projects..Coviddeaths
Group by location, population
order by Percentageofpopulationinfected desc

-- Showing countries with highest death count per population
SELECT location, Population, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM Portfolio_Projects..Coviddeaths
WHERE continent is not null
Group by location, population
order by Totaldeathcount desc

-- Breaking down by continent showing continent with the highest death count by population
SELECT continent, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM Portfolio_Projects..Coviddeaths
WHERE continent is not null
Group by continent
order by Totaldeathcount desc

-- Global numbers
SELECT date,
sum(new_cases) as newcases, SUM(new_deaths) as newdeaths, 
SUM(new_deaths)/sum(nullif(new_cases,0)) * 100 as Deathpercentage
FROM Portfolio_Projects..Coviddeaths
WHERE continent is not null
Group by date
order by Deathpercentage desc

-- Looking at Total population vs vaccinations
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations, sum(convert(bigint, nullif(new_vaccinations,0))) over(partition by dea.location Order by Dea.location, Dea.Date) as Cumulativeofpeoplevaccinated
-- (Cumulativeofpeoplevaccinated/population) * 100
from Portfolio_Projects..Coviddeaths Dea
join Portfolio_Projects..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
Order by 2,3

-- Using CTE
with PopuvsVac (Continent, Location, Date, population, new_vaccinations, cumulativeofpeoplevaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations, 
sum(convert(bigint, nullif(new_vaccinations,0))) over(partition by dea.location Order by Dea.location, Dea.Date) as Cumulativeofpeoplevaccinated
from Portfolio_Projects..Coviddeaths Dea
join Portfolio_Projects..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
-- Order by 2,3
)
Select *, (cumulativeofpeoplevaccinated/population) as vaccinatedpeople_populationratio
From PopuvsVac

--Using Temp table
Drop Table if exists #PercentPopulationvaccinated
CREATE Table #PercentPopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
cumulativeofpeoplevaccinated numeric
)

Insert into #PercentPopulationvaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations, 
sum(convert(bigint, nullif(new_vaccinations,0))) over(partition by dea.location Order by Dea.location, Dea.Date) as Cumulativeofpeoplevaccinated
from Portfolio_Projects..Coviddeaths Dea
join Portfolio_Projects..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
--Where Dea.continent is not null
-- Order by 2,3

Select *, (cumulativeofpeoplevaccinated/population) as vaccinatedpeople_populationratio
From #PercentPopulationvaccinated

--Creating Views for future visualizations
Create view Populationvaccinatedpercent as
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations, 
sum(convert(bigint, nullif(new_vaccinations,0))) over(partition by dea.location Order by Dea.location, Dea.Date) as Cumulativeofpeoplevaccinated
from Portfolio_Projects..Coviddeaths Dea
join Portfolio_Projects..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
-- Order by 2,3

Create view GlobalNumbers as 
SELECT date,
sum(new_cases) as newcases, SUM(new_deaths) as newdeaths, 
SUM(new_deaths)/sum(nullif(new_cases,0)) * 100 as Deathpercentage
FROM Portfolio_Projects..Coviddeaths
WHERE continent is not null
Group by date
--order by Deathpercentage desc

Create View Breakdownofcontinentwithhighestdeathcount as
SELECT continent, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM Portfolio_Projects..Coviddeaths
WHERE continent is not null
Group by continent
--order by Totaldeathcount desc


