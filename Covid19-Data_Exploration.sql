

--Selecting Data That will be used:
select
 location,
 date, 
 total_cases, 
 new_cases, 
 total_deaths, 
 population
from
 MSBA23..covid_deaths
order by
 1,2

--Total cases versus Total deaths
--Shows the chance of dying if you catch covid
select
 location,
 date, 
 total_cases, 
 total_deaths,
 (cast(total_deaths as numeric) / total_cases)*100 as [Death_Percentage]
from
 MSBA23..covid_deaths
where
 location = 'United States'
order by
 1,2


--Looking at total cases versus population:
--Percentage of the population that have contracted covid-19
select
 location,
 date, 
 total_cases, 
 population,
 (total_cases/population)*100 as [Percent Population Infected]
from
 MSBA23..covid_deaths
where
 location = 'United States' 
order by
 1,2

--Looking at countries with highest infection rate compared to population:
select
 location,
 max(total_cases) as [Highest Infection Count], 
 population,
 max((total_cases/population))*100 as [Percent Population Infected]
from
 MSBA23..covid_deaths
where
 continent is not null
group by
 location,
 population
order by
 [Percent Population Infected] DESC

--Showing countries with highest death count:
select
 location,
 max(cast(total_deaths as int)) as [total death count]
from
 MSBA23..covid_deaths
where
 continent is not null
group by
 location
order by
 [total death count] DESC

--Showing Continents with the highest Death count per population:
select
 continent,
 max(cast(total_deaths as int)) as [total death count]
from
 MSBA23..covid_deaths
where
 continent is not null
group by
 continent
order by
 [total death count] DESC

--Global Numbers:
select
 date, 
 sum(new_cases) as [Total Global Cases],
 sum(cast(new_deaths as int)) as [Total Global Deaths]
from
 MSBA23..covid_deaths
where
 continent is not null
group by
 date
order by
 1,2

--Joining our covid_death table with covid_vaccination table for deeper analysis:
select
*
from
 msba23..covid_deaths as cd
 join msba23..covid_vaccinations as cv
 on cd.location = cv.location
 and cd.date = cv.date

--Looking at total population vs vaccinations:
with pop_vs_vac (location, continent, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select
 cd.location, 
 cd.continent, 
 cd.date, 
 cd.population, 
 cv.new_vaccinations,
 sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as rolling_people_vaccinated
 --([rolling people vaccinated]/cd.population)*100
from
 msba23..covid_deaths as cd
 join msba23..covid_vaccinations as cv
 on cd.location = cv.location
 and cd.date = cv.date
where
 cd.continent is not null
--order by
--1,3
)
select
 *,
 (rolling_people_vaccinated/population)*100 as [Total people vaccinated %]
from
 pop_vs_vac


--Temp Table:
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_people_vaccinated numeric)
insert into #PercentPopulationVaccinated
select
 cd.location, 
 cd.continent, 
 cd.date, 
 cd.population, 
 cv.new_vaccinations,
 sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as rolling_people_vaccinated
 --([rolling people vaccinated]/cd.population)*100
from
 msba23..covid_deaths as cd
 join msba23..covid_vaccinations as cv
 on cd.location = cv.location
 and cd.date = cv.date
where
 cd.continent is not null
--order by
--1,3
select
 *,
 (rolling_people_vaccinated/population)*100 as [Total people vaccinated %]
from
 #PercentPopulationVaccinated


--Creating View to store data for later visualizations:
Create View PercentPopulationVaccinated as
select
 cd.location, 
 cd.continent, 
 cd.date, 
 cd.population, 
 cv.new_vaccinations,
 sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as rolling_people_vaccinated
 --([rolling people vaccinated]/cd.population)*100
from
 msba23..covid_deaths as cd
 join msba23..covid_vaccinations as cv
 on cd.location = cv.location
 and cd.date = cv.date
where
 cd.continent is not null
--order by
--1,3



 

