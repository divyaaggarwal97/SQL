/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, 
Creating Views, Converting Data Types,
String functions

*/

-- Data 
select top 5 * from CovidDeaths
where continent is not null
select top 5 * from CovidVaccinations
where continent is not null

-- Total Cases vs Total Deaths
-- Shows what percentage of covid affected population died(continent-wise)

select continent,max(total_cases) as CasesFiled,max(cast (total_deaths as int)) as Deaths,
(max(cast (total_deaths as int))/max(total_cases))*100 as DeathRate
from CovidDeaths
where continent is not null
group by continent
order by CasesFiled desc

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid (country-wise)

select location , max (population) as population , max(total_cases) as cases ,
(max(total_cases)/max (population))*100 as affectedRate
from CovidDeaths
where continent is not null
group by location
order by affectedRate desc


-- Shows deaths of covid patients in your country date wise (Ex: INDIA)

Select substring (cast (date as varchar(30)),1,11) as date,cast (total_deaths as int)as deaths
From CovidDeaths
Where location = 'India' and continent is not null 
order by cast (total_deaths as int) desc

-- Vaccination rate vs Death rate
-- Shows the death rate and vaccine rate of the countries 

Select location,population, max(people_fully_vaccinated) as fully_vaccinated_People, 
(max(cast(people_fully_vaccinated as bigint))/population)*100 as vaccineRate ,
max(cast(total_deaths as bigint))/population*100 as deathRate
From CovidDeaths
where continent is not null 
group by location,population
order by vaccineRate desc

-- Date wise cases and deaths globally

select substring(cast(date as varchar(100)),1,12) as date, sum(total_cases) as totalCases
from CovidDeaths
where continent is not null
group by date
order by totalCases desc

-- Showing cumulative cases count globally - country vaccinations 

select dea.location, dea.date , population,vac.new_vaccinations , 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location= vac.location and dea.date= vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by location 

-- CTE
with VaccVsPop (Location,Date,population,new_vaccinations,CumulativeCountofVaccinatedPeople)
as
(
select dea.location, dea.date , population,vac.new_vaccinations , 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) 
as CumulativeCountofVaccinatedPeople from CovidDeaths dea
join CovidVaccinations vac
on dea.location= vac.location and dea.date= vac.date
where dea.continent is not null and vac.new_vaccinations is not null
 
)
select Location,date,population,
CumulativeCountofVaccinatedPeople/population*100 as CumulativeVAccineRate from VaccVsPop

-- Temp Tables
-- Vaccination rate vs Death rate
-- Shows the death rate and vaccine rate of the countries 

drop table if exists  #VaccineVsDeathRate 
create table #VaccineVsDeathRate
(location varchar(50),
population bigint,
people_vaccinated bigint,
VaccineRate float,
DeathRate float
)

insert into #VaccineVsDeathRate

Select dea.location,population, max(vac.people_fully_vaccinated) as fully_vaccinated_People, 
(max(cast(vac.people_fully_vaccinated as bigint))/population)*100 as vaccineRate ,
max(cast(total_deaths as bigint))/population*100 as deathRate
From CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
group by dea.location,population
order by vaccineRate desc

select * from #VaccineVsDeathRate

-- Creating view for tableu visualizations

create view VaccineVsDeathRate 
as 
Select dea.location,population, max(vac.people_fully_vaccinated) as fully_vaccinated_People, 
(max(cast(vac.people_fully_vaccinated as bigint))/population)*100 as vaccineRate ,
max(cast(total_deaths as bigint))/population*100 as deathRate
From CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
group by dea.location,population