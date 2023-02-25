select location,date,total_cases,new_cases,total_deaths,population
from CVDdeaths
order by 1,2 

-- Select Data that we are going to be starting with


select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as alias
from CVDdeaths
where location like '%india%'
order by 1,2 

--Total Cases vs Total Deaths

select location,population,MAX(total_cases)as highinfcount , max((total_cases/population))*100 as dethpercent
from CVDdeaths
group by location , population
order by dethpercent desc

-- hght deaths cnt 

select location,MAX(cast(total_deaths as int))as totaldeathcount
from CVDdeaths
where continent is not null
group by location 
order by totaldeathcount desc

--by continent 


select location,MAX(cast(total_deaths as int))as totaldeathcount
from CVDdeaths
where continent is null
group by location 
order by totaldeathcount desc

--continet with hight deth rte 

select continent,MAX(cast(total_deaths as int))as totaldeathcount
from CVDdeaths
where continent is null
group by location 
order by totaldeathcount desc


--brek to global 

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(
new_deaths as int ))/ SUM(new_cases)*100 as dthprct
from CVDdeaths
--where location like '%india%'
where continent is not null
--group by date 
order by 1,2



-- pppl vs vccntom
 
with popvsvac (continent,location,date,population ,new_vaccinations,rllgpplvcc )
as
(
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date )
as rllgpplvcc
from CVDdeaths dea
join CVDvacitination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
--order by 2,3 
)
select *,(rllgpplvcc/population)*100
from popvsvac

--temp tabole


drop table if exists #prcntvcc
create table #prcntvcc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacctinated numeric,
rllgpplvcc numeric
)

insert into #prcntvcc
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date )
as rllgpplvcc
from CVDdeaths dea
join CVDvacitination vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null 
--order by 2,3 

select *,(rllgpplvcc/population)*100
from #prcntvcc



Create View prcntvcc as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CVDdeaths dea
Join CVDvacitination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
