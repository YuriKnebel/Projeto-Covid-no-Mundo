-- Utiliza��o do banco de dados covid

USE covid;

-- Vis�o geral dos dados

SELECT 
	*
FROM 
	covid_vacinas;

SELECT 
	*
FROM 
	covid_mortes;

-- 100 primeiros dados, ordenados por pa�s e continente

SELECT 
	*
FROM 
	(SELECT row_number() OVER (ORDER BY continent, location) AS row_number, * FROM covid_mortes) covid_mortes
WHERE 
	ROW_NUMBER <= 100;

SELECT 
	*
FROM 
	(SELECT row_number() OVER (ORDER BY continent, location) AS row_number, * FROM covid_vacinas) covid_vacinas
WHERE 
	ROW_NUMBER <= 100;

-- Sele��o dos dados mais relevantes de mortes ordenados por pa�s e data

SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM 
	covid_mortes
ORDER BY 
	1, 2;

-- Verificando os pa�ses com a maior quantidade de mortes

SELECT 
	location, MAX(total_deaths) AS max_total_death
FROM 
	covid_mortes
GROUP BY 
	location
ORDER BY 
	max_total_death DESC;

-- Na an�lise acima temos problemas pois era para aparecer apenas pa�ses
-- e est� aparecendo dados do mundo e de continentes
-- A corre��o est� abaixo

SELECT 
	location, MAX(total_deaths) AS max_total_death
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY 
	max_total_death DESC;

-- Para visualizar a quantidade de mortes por continente podemos fazer conforme a seguir

SELECT 
	continent, SUM(max_total_deaths) AS continent_total_death
FROM 
	(SELECT location, continent, MAX(total_deaths) AS max_total_deaths FROM covid_mortes GROUP BY continent, location) covid_death
WHERE 
	continent IS NOT NULL
GROUP BY 
	continent
ORDER BY 
	continent_total_death DESC;

-- casos vs mortes ao longo do tempo

SELECT 
	location, date, total_cases, total_deaths, (CAST(total_deaths AS bigint)/CAST(total_cases AS float)*100) AS death_percentage
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL
	--AND location like 'Brazil'
ORDER BY 
	1,2;

-- casos vs popula��o ao longo do tempo

SELECT 
	location, date, total_cases, population, (CAST(total_cases AS float)/population*100) AS cases_percentual
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL
-- AND location like 'Brazil'
ORDER BY 
	1,2;

-- Localizando os pa�ses com a maior taxa de infec��o

SELECT 
	location, population, MAX(total_cases) AS highest_infection_count, MAX((CAST(total_cases AS float)/population))*100 AS infected_percentual
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL
GROUP BY 
	location, population
ORDER BY 
	4 DESC;

-- Localizando os pa�ses com a maior taxa de morte

SELECT 
	location, SUM(CAST(total_cases AS bigint)) AS total_cases, SUM(CAST(total_deaths AS bigint)) AS total_deaths, (SUM(CAST(total_deaths AS float))/SUM(CAST(total_cases AS bigint))*100) AS death_percentage
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY 
	death_percentage DESC;

-- N�meros globais de casos e mortes

SELECT 
	SUM(new_cases) AS cases, SUM(new_deaths) AS deaths, SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS death_percentage --total_deaths, (CAST(total_deaths AS bigint)/CAST(total_cases AS float)*100) AS death_percentage
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL
ORDER BY 
	1,2;

-- Quantidade de vacina��es vs popula��o

SELECT
	cm.continent, cm.location, cm.date, cm.population, cv.new_vaccinations, 
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY  cm.location ORDER BY cm.location, cm.date) AS acumulado_vacinacao
FROM 
	covid_mortes AS cm
JOIN 
	covid_vacinas AS cv
	ON cm.location = cv.location
	AND cm.date = cv.date
WHERE 
	cm.continent IS NOT NULL
ORDER BY 
	location, date;

-- Utiliza��o de CTE para calcular o percentual de vacina��o em rela��o � popula��o

WITH 
	popvsvac (continent, location, date, population, new_vaccinations, acumulado_vacinacao) AS (
		SELECT
			cm.continent, cm.location, cm.date, cm.population, cv.new_vaccinations, 
			SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY  cm.location ORDER BY cm.location, cm.date) AS acumulado_vacinacao
		FROM 
			covid_mortes AS cm
		JOIN 
			covid_vacinas AS cv
			ON cm.location = cv.location
			AND cm.date = cv.date
		WHERE 
			cm.continent IS NOT NULL
			)

SELECT
	*, (CAST(acumulado_vacinacao AS float)/CAST(population AS float))*100
FROM 
	popvsvac

-- O c�digo acima tem como problema o fato das pessoas tomarem mais de uma dose da vacina,
-- por tal motivo o percentual acaba ultrapassando 100%
-- Abaixo foi utilizada a coluna people_fully_vaccinated em compara��o com a popula��o

SELECT
	cm.continent, cm.location, cm.date, cm.population, cv.people_fully_vaccinated, (CAST(cv.people_fully_vaccinated AS float)/cm.population)*100 AS percentage_fully_vaccinated
FROM 
	covid_mortes AS cm
JOIN 
	covid_vacinas AS cv
	ON cm.location = cv.location
	AND cm.date = cv.date
WHERE 
	cm.continent IS NOT NULL
ORDER BY 
	location, date;

-- Criando Views para utilizar no PowerBI

CREATE VIEW numeros_globais
AS
SELECT 
	SUM(new_cases) AS cases, SUM(new_deaths) AS deaths, SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS death_percentage --total_deaths, (CAST(total_deaths AS bigint)/CAST(total_cases AS float)*100) AS death_percentage
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL;

CREATE VIEW total_mortes_paises
AS
SELECT 
	location, MAX(total_deaths) AS max_total_death
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL
GROUP BY 
	location;

CREATE VIEW total_mortes_continentes
AS
SELECT 
	continent, SUM(max_total_deaths) AS continent_total_death
FROM 
	(SELECT location, continent, MAX(total_deaths) AS max_total_deaths FROM covid_mortes GROUP BY continent, location) covid_death
WHERE 
	continent IS NOT NULL
GROUP BY 
	continent;

CREATE VIEW casos_mortes_tempo
AS
SELECT 
	location, date, total_cases, total_deaths, (CAST(total_deaths AS bigint)/CAST(total_cases AS float)*100) AS death_percentage
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL;

CREATE VIEW casos_populacao_tempo
AS
SELECT 
	location, date, total_cases, population, (CAST(total_cases AS float)/population*100) AS cases_percentual
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL;

CREATE VIEW taxa_infeccao_paises
AS
SELECT 
	location, population, MAX(total_cases) AS highest_infection_count, MAX((CAST(total_cases AS float)/population))*100 AS infected_percentual
FROM 
	covid_mortes
WHERE 
	continent IS NOT NULL
GROUP BY 
	location, population;

CREATE VIEW vacinacao_completa_populacao
AS
SELECT
	cm.continent, cm.location, cm.date, cm.population, cv.people_fully_vaccinated, (CAST(cv.people_fully_vaccinated AS float)/cm.population)*100 AS percentage_fully_vaccinated
FROM 
	covid_mortes AS cm
JOIN 
	covid_vacinas AS cv
	ON cm.location = cv.location
	AND cm.date = cv.date
WHERE 
	cm.continent IS NOT NULL;