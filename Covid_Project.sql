
USE Portfolio_project
select * from Covid_death
where continent is not null
order by 3,4


select * from Covid_vaccination
order by 3,4

-- Select Data
Select location,date,total_cases,new_cases,total_deaths,population
FROM Covid_death
order by 1,2


alter table Covid_death
alter column total_deaths bigint

select * from Covid_vaccination
order by date

-- total cases vs total death

Select location,date,total_cases,total_deaths, ((total_deaths/total_cases)*100)as DeathPercentage
FROM Covid_death
where location = 'Indonesia'
order by location,date


--total cases vs population
Select location,date,total_cases,population, ((total_cases/population)*100)as CasesPercentage
FROM Covid_death
where location = 'Indonesia'
order by location,date

--4
Select location,population,date,max(total_cases) as HigestInfectionCount, MAX(((total_cases/population)*100))as PercentPopulationInfected
FROM Covid_death
where continent is not null
group by location,population,date
order by PercentPopulationInfected desc

--highest infected country
--3
Select location,population,max(total_cases) as HigestInfectionCount, MAX(((total_cases/population)*100))as PercentPopulationInfected
FROM Covid_death
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--highest death count country percentage
Select location,population,max(cast(total_deaths as int)) as TotalDeath, MAX(((total_deaths/population)*100))as DeathPercentage
FROM Covid_death
where continent is not null
group by location,population
order by DeathPercentage desc




--country with highest death number

select location,max(cast(total_deaths as int)) as TotalDeath
FROM Covid_death
where continent != ' '
group by location
order by TotalDeath desc

-- TOTAL DEATH BY CONTINENT
--2
select continent,SUM(cast(new_deaths as bigint)) as TotalDeath
FROM Covid_death
where continent!= ' '
group by continent
order by TotalDeath desc

--Showing continent with the highest death count per population
select continent,max(cast(total_deaths as int)) as TotalDeath
FROM Covid_death
where continent != ' '
group by continent
order by TotalDeath desc


--GLOBAL NUMBERS
--1
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --,total_deaths, ((total_deaths/total_cases)*100)as DeathPercentage
FROM Covid_death
--where location = 'Indonesia' and 
where continent!=' '
--group by date
order by 1,2

select * 
From Covid_vaccination cv join Covid_death cd 
on cv.location = cd.location and cv.date = cd.date

-- Looking at total population vs vaccinations
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations , 
SUM(CAST(cv.new_vaccinations as float)) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Covid_vaccination cv join Covid_death cd 
on cv.location = cd.location and cv.date = cd.date
where cd.continent !=' '
order by 2,3

--USE CTE
WITH PopvsVac(COntinent,Location,Date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations , 
SUM(CAST(cv.new_vaccinations as float)) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Covid_vaccination cv join Covid_death cd 
on cv.location = cd.location and cv.date = cd.date
where cd.continent !=' '
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
FROM PopvsVAC


 --TEMP TABLE
 Drop table if exists #PercentPopulationVaccinated
 Create TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccination float,
 RollingPeopleVaccinated numeric
 )
 INSERT INTO #PercentPopulationVaccinated
 select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations , 
SUM(CAST(cv.new_vaccinations as float)) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Covid_vaccination cv join Covid_death cd 
on cv.location = cd.location and cv.date = cd.date
where cd.continent !=' '
--order by 2,3
Select * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Create View to store data for visualizations
Create View PercentPopulationVaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations , 
SUM(CAST(cv.new_vaccinations as float)) over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From Covid_vaccination cv join Covid_death cd 
on cv.location = cd.location and cv.date = cd.date
where cd.continent !=' '
--order by 2,3


--Create View TOTAL DEATH BY CONTINENT
Create View ContinentDeath as
select continent,max(cast(total_deaths as int)) as TotalDeath
FROM Covid_death
where continent != ' '
group by continent
--order by TotalDeath desc

select * from ContinentDeath

drop table #PercentPopulationVaccinated

drop table Covid_death
drop table Covid_vaccination






