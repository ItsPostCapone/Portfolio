-- Below Case study is querying Covid data. 
-- The below data is pulled from https://ourworldindata.org/covid-deaths
-- The data is extracted as CSV
-- The ETL process goes as such:
	-- step 1 pull data
	-- step 2 import csv to excel and delete unwanted rows
	-- step 3 imput formula to calculate % totals
	-- step 4 in SQL Query window, create new database for the project
	-- step 5 load both data sets into the database as seperate tables
	-- step 6 open a new query window

--Covid 19 Data Exploration 
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
--*/


--queries Covid 19 Data Exploration 
--query 1 to check if data is loaded correctly

Select *
From PortfolioProject1..CovidDeaths
Where continent is not null 
order by 3,4

--query 2
-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Where continent is not null 
order by 1,2

--query 3
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
-- US specific 

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

--query 3
-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
-- US specific 

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
order by 1,2

--query 4
-- Countries with Highest Infection Rate compared to Population
-- order by highest percentage

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--query 5
-- Countries with Highest Death Count per Population
--ordered by highest death count

Select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


--query 6
-- BREAKING THINGS DOWN BY CONTINENT
-- order by highest deathcount
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--query 7
-- GLOBAL NUMBERS
--looking at highlevel view
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--query 8
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
 

 --query 9
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

