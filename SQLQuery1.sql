Select *
From PortfolioProject..CovidDeaths
Order By 3,4



Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2



Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Pak%'
Order By 1,2



Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order By 1,2



Select Location, MAX(total_cases) as HighestInfectCount, Population, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group By Location , population
Order By PercentPopulationInfected desc



Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location , population
Order By TotalDeathCount desc



-- Breaking Things by Continent --

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc



-- Global Numbers --

Select SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths , (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2


-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
Order By 1,2,3


-- USE CTE 

With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac




-- TEMP TABLE


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
Order By 1,2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




-- CREATING VIEW TO STORE DATA FOR LATE VISUALIZATION


Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order By 2,3 


Select *
From PortfolioProject..PercentPopulationVaccinated