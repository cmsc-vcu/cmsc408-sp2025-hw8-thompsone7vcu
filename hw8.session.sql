show tables;
drop table if exists skills;
select * from wdi_country;
select count(*) as "Country Count" from wdi_country;
select region from wdi_country group by region;
select region from wdi_country;

select * FROM wdi_country 
WHERE `Region` = "North America";

select * from wdi_country;

select
  `Region`, `Income Group`, count(*) as "Number of Countries"
from 
  wdi_country
group by `Region`, `Income Group`;

SELECT
    `Region`,
    SUM(CASE WHEN  `Income Group` = 'High income' THEN 1 ELSE 0 END) AS 'High income',
    SUM(CASE WHEN `Income Group` = 'Upper middle income' THEN 1 ELSE 0 END) AS 'Upper middle income',
    SUM(CASE WHEN `Income Group` = 'Lower middle income' THEN 1 ELSE 0 END) AS 'Lower middle income',
    SUM(CASE WHEN `Income Group` = 'Low income' THEN 1 ELSE 0 END) AS 'Low income',
    SUM(CASE WHEN `Income Group` IS NULL OR `Income Group` NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income') THEN 1 ELSE 0 END) AS 'Other income',
    COUNT(*) AS `Total Countries`
FROM
    wdi_country
GROUP BY
    `Region`
ORDER BY
    `Region`;


SELECT 
    r.`Region`,
    i.`Income Group`
FROM 
    (SELECT DISTINCT `Region` FROM wdi_country) r
CROSS JOIN 
    (SELECT DISTINCT `Income Group` FROM wdi_country) i
LEFT JOIN 
    (
        SELECT `Region`, `Income Group`
        FROM wdi_country
        GROUP BY `Region`, `Income Group`
    ) existing_pairs
ON 
    r.`Region` = existing_pairs.`Region` AND i.`Income Group` = existing_pairs.`Income Group`
WHERE 
    existing_pairs.`Region` IS NULL
ORDER BY 
    r.`Region`, i.`Income Group`;

select 
  `Region`, 
  `Income Group`, 
  count(*) as "Country Count",

  (select count(*) from wdi_country as r
   where r.`Region` = wdi_country.`Region`) as "Countries by Region",

  (select count(*) from wdi_country as i
   where i.`Income Group` = wdi_country.`Income Group`) as "Countries by Income",

   (select count(*) from wdi_country) as "Total Sum Countries",

   round (count(*) * 100.0 / (select count(*) from wdi_country), 2) as "Percent"
from 
  wdi_country
group by
  `Region`, `Income Group`
order by 
  `Region`, `Income Group`;


WITH 
-- Total countries
total_countries AS (
  SELECT COUNT(*) AS total FROM wdi_country
),

-- Countries per region
region_totals AS (
  SELECT `Region`, COUNT(*) AS region_count
  FROM wdi_country
  WHERE `Region` IS NOT NULL
  GROUP BY `Region`
),

-- Countries per income group
income_totals AS (
  SELECT `Income Group`, COUNT(*) AS income_count
  FROM wdi_country
  WHERE `Income Group` IS NOT NULL
  GROUP BY `Income Group`
),

-- Main counts per region + income group
region_income_counts AS (
  SELECT 
    `Region`, 
    `Income Group`, 
    COUNT(*) AS country_count
  FROM wdi_country
  WHERE `Region` IS NOT NULL AND `Income Group` IS NOT NULL
  GROUP BY `Region`, `Income Group`
)

-- Final select
SELECT 
  ric.`Region`,
  ric.`Income Group`,
  ric.country_count,
  rt.region_count AS "Countries by Region",
  it.income_count AS "Countries by Income",
  tc.total AS "Total Sum Countries",
  ROUND(ric.country_count * 100.0 / tc.total, 2) AS "Percent"
FROM 
  region_income_counts ric
JOIN 
  region_totals rt ON ric.`Region` = rt.`Region`
JOIN 
  income_totals it ON ric.`Income Group` = it.`Income Group`
CROSS JOIN 
  total_countries tc
ORDER BY 
  ric.`Region`, ric.`Income Group`;




WITH total_countries AS (
    SELECT COUNT(*) AS total FROM wdi_country
),
region_income_counts AS (
    SELECT 
        `Region`,
        `Income Group`,
        COUNT(*) AS country_count
    FROM wdi_country
    WHERE `Region` IS NOT NULL AND `Income Group` IS NOT NULL
    GROUP BY `Region`, `Income Group`
)
SELECT
    r.`Region`,

    ROUND(SUM(CASE WHEN r.`Income Group` = 'High income' THEN r.country_count ELSE 0 END) * 100.0 / MAX(t.total), 2) AS "High income",
    ROUND(SUM(CASE WHEN r.`Income Group` = 'Upper middle income' THEN r.country_count ELSE 0 END) * 100.0 / MAX(t.total), 2) AS "Upper middle",
    ROUND(SUM(CASE WHEN r.`Income Group` = 'Lower middle income' THEN r.country_count ELSE 0 END) * 100.0 / MAX(t.total), 2) AS "Lower middle",
    ROUND(SUM(CASE WHEN r.`Income Group` = 'Low income' THEN r.country_count ELSE 0 END) * 100.0 / MAX(t.total), 2) AS "Low income",
    ROUND(SUM(CASE WHEN r.`Income Group` IS NULL OR r.`Income Group` NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income') 
              THEN r.country_count ELSE 0 END) * 100.0 / MAX(t.total), 2) AS "Other"

FROM 
    region_income_counts r
CROSS JOIN 
    total_countries t
GROUP BY 
    r.`Region`, r.`Income Group`
ORDER BY 
    r.`Region`, r.`Income Group`;



WITH total_count AS (
    SELECT COUNT(*) AS total FROM wdi_country
)

SELECT 
    `Income Group`,
    COUNT(*) AS "Country Count",
    (SELECT total FROM total_count) AS "Total Countries",
    ROUND(COUNT(*) * 100.0 / (SELECT total FROM total_count), 2) AS "Percent of Total Countries"
FROM 
    wdi_country
GROUP BY 
    `Income Group`
ORDER BY 
    `Percent of Total Countries` DESC;
