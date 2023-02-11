SELECT *
FROM Covid_Deaths cd 
WHERE location = 'Asia'
WHERE continent is not null
order by 3,4

/*
SELECT *
FROM Covid_Vaccinations cv 		
order by 3,4
*/

-- Selecting data that will be used for project
SELECT LOCATION, DATE, TOTAL_CASES,NEW_CASES, TOTAL_DEATHS, POPULATION
FROM Covid_Deaths cd 
ORDER BY 1,2


-- Looking at Total cases vs Total Deaths in the UK

SELECT LOCATION, DATE, TOTAL_CASES, TOTAL_DEATHS, (TOTAL_DEATHS/TOTAL_CASES)*100 as Death_Percentage
FROM Covid_Deaths cd 
WHERE LOCATION = 'United Kingdom'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT LOCATION, POPULATION , MAX(TOTAL_CASES) as HighestInfectionCount, MAX((TOTAL_CASES/population))*100 as InfectionRate
FROM Covid_Deaths cd 
-- WHERE LOCATION = 'United Kingdom'
GROUP BY location,population 
ORDER BY InfectionRate desc

-- Looking at countries with highest death count per population
SELECT location, MAX(TOTAL_DEATHS) AS TotalDeathCount
FROM Covid_Deaths cd 
-- WHERE LOCATION = 'United Kingdom'
WHERE continent is not NULL 
GROUP BY location 
ORDER BY TotalDeathCount desc


 -- Breaking down via continent:
SELECT location, MAX(TOTAL_DEATHS) AS TotalDeathCount
FROM Covid_Deaths cd 
-- WHERE LOCATION = 'United Kingdom'
WHERE continent = '' AND location NOT LIKE '%income%' AND location NOT LIKE '%union%' AND location != 'International'
-- WHERE location NOT LIKE %income%
GROUP BY location 
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage
FROM Covid_Deaths cd 
-- WHERE LOCATION = 'United Kingdom'
WHERE continent != ''
GROUP BY DATE
ORDER BY 1,2




WITH pop_vs_vac (continent, location, date, population, new_vaccinations, Total_Vaccinations_Delivered)

AS 
(
-- Looking at Total Population vs Vaccinations in United Kingdom

SELECT DISTINCT cd.continent, cd.location, STR_TO_DATE(cd.date , "%d/%m/%Y" ) as date
,cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location,(STR_TO_DATE(cd.date , "%d/%m/%Y" ))) AS Total_Vaccinations_Delivered
FROM Covid_Deaths cd 
JOIN Covid_Vaccinations cv on CD.location = CV.location and CD.date = CV.date
WHERE CD.continent != ''  AND cd.location = 'United Kingdom'
ORDER BY 2,3
)
/* The query above is a bit more involved and required a bit more thinking to accurately set up. 
 * Firstly, selected DISTINCT values, as for some reason date values were being repeated in the query 4 times. Probably due to the JOIN
 * STR_TO_DATE has been used for the date column as it has originally been formatted as a VARCHAR2 column. Needed it in MySQL date format for ease of data manipulation. 
 * SUM(cv.new_vaccinations) used here to SUM total vaccinations. If left like this the query would return only the total GLOBAL vaccinations. We need to PARTITION the SUM function OVER cd.location then order by location and date. /4 was used as a  quick fix to eliminate the 3 repeated values as in the case for Afghanistan(Need further investigation to check this). 
 *  cv and cd tables are then joined on location and date
 *  */


-- Now we want Total Vaccinations Delivered as a percentage. However, since that column was initialised in the query we'll need a CTE to do this:
SELECT * ,
(Total_Vaccinations_Delivered/population)*100
FROM pop_vs_vac



-- Can do the same thing as above but using a Temp table! Temp table can be used 

-- DROP TABLE IF EXISTS PPV
CREATE TEMPORARY TABLE PPV(
Continent varchar(50),
Location varchar(50),
Date varchar(50),
Population int,
New_vaccinations varchar(50),
Total_Vaccinations_Delivered varchar(50)
)

INSERT INTO PPV

SELECT DISTINCT cd.continent, cd.location, STR_TO_DATE(cd.date , "%d/%m/%Y" ) as date
,cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location,(STR_TO_DATE(cd.date , "%d/%m/%Y" ))) AS Total_Vaccinations_Delivered
FROM Covid_Deaths cd 
JOIN Covid_Vaccinations cv on CD.location = CV.location and CD.date = CV.date
WHERE CD.continent != ''  AND cd.location = 'United Kingdom'
-- ORDER BY 2,3


SELECT * 
, (Total_Vaccinations_Delivered/population)*100 
FROM PPV


-- Create view for later visualisations
CREATE VIEW PercentagePopulatedVaccinated AS
SELECT DISTINCT cd.continent, cd.location, STR_TO_DATE(cd.date , "%d/%m/%Y" ) as date
,cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location,(STR_TO_DATE(cd.date , "%d/%m/%Y" ))) AS Total_Vaccinations_Delivered
FROM Covid_Deaths cd 
JOIN Covid_Vaccinations cv on CD.location = CV.location and CD.date = CV.date
WHERE CD.continent != ''  -- AND cd.location = 'United Kingdom'
-- ORDER BY 2,3


-- Make some more views that will be useful for visualisation!
