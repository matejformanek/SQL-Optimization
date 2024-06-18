-- Naive
SELECT city, district, name, am_sold
FROM (SELECT city, district, name, SUM(amount_sold) AS am_sold
      FROM drug
               JOIN public.sold ON drug.drug_id = sold.drug_id
               JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
      GROUP BY city, district, name) AS c
WHERE am_sold = (SELECT MAX(am_sold)
                 FROM (SELECT name, SUM(amount_sold) AS am_sold
                       FROM drug
                                JOIN public.sold ON drug.drug_id = sold.drug_id
                                JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
                       GROUP BY city, district, name) AS cte
                 WHERE c.name = cte.name
                 GROUP BY name)
ORDER BY am_sold DESC;

-- CTE
WITH cte AS (SELECT city, district, name, SUM(amount_sold) AS am_sold
             FROM drug
                      JOIN public.sold ON drug.drug_id = sold.drug_id
                      JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
             GROUP BY city, district, name)
SELECT city, district, name, am_sold
FROM cte c
WHERE am_sold = (SELECT MAX(am_sold)
                 FROM cte
                 WHERE c.name = cte.name
                 GROUP BY name)
ORDER BY am_sold DESC;

-- HAVING
WITH cte AS (SELECT city, district, name, SUM(amount_sold) AS am_sold
             FROM drug
                      JOIN public.sold ON drug.drug_id = sold.drug_id
                      JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
             GROUP BY city, district, name)
SELECT city, district, name, am_sold
FROM cte c
GROUP BY city, district, name, am_sold
HAVING MAX(c.am_sold) = (SELECT MAX(am_sold)
                         FROM cte
                         WHERE name = c.name
                         GROUP BY name)
ORDER BY am_sold DESC;

-- OPTIMIZED
WITH cte AS (SELECT city, district, name, SUM(amount_sold) AS am_sold
             FROM drug
                      JOIN public.sold ON drug.drug_id = sold.drug_id
                      JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
             GROUP BY city, district, name)
SELECT city, district, c.name, am_sold
FROM cte c
         JOIN (SELECT name, MAX(am_sold) AS am
               FROM cte
               GROUP BY name) AS ag ON ag.am = c.am_sold AND ag.name = c.name
ORDER BY am_sold DESC;

-- SUM of all MAXES
WITH cte AS (SELECT city, district, name, SUM(amount_sold) AS am_sold
             FROM drug
                      JOIN public.sold ON drug.drug_id = sold.drug_id
                      JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
             GROUP BY city, district, name)
SELECT city, district, c.name, COALESCE(c.am_sold, SUM(am_sold) OVER ())
FROM cte c
         RIGHT JOIN (SELECT name, MAX(am_sold) AS am
                     FROM cte
                     GROUP BY ROLLUP (name)) AS ag ON ag.am = c.am_sold AND ag.name = c.name
ORDER BY am_sold DESC;

-- Could be written as
WITH cte AS (SELECT city, district, name, SUM(amount_sold) AS am_sold
             FROM drug
                      JOIN public.sold ON drug.drug_id = sold.drug_id
                      JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
             GROUP BY city, district, name)
SELECT city, district, c.name, COALESCE(c.am_sold, SUM(am_sold) OVER ())
FROM cte c
         RIGHT JOIN (SELECT name, MAX(am_sold) AS am
                     FROM cte
                     GROUP BY name
                     UNION ALL
                     SELECT NULL, NULL) AS ag ON ag.am = c.am_sold AND ag.name = c.name
ORDER BY am_sold DESC;

-- More stats
WITH cte AS (SELECT city, district, name, SUM(amount_sold) AS am_sold
             FROM drug
                      JOIN public.sold ON drug.drug_id = sold.drug_id
                      JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
             GROUP BY GROUPING SETS ((city, district, name), (city, name), (name)))
-- Possible ROLLUP (name, city, district)
SELECT DISTINCT ON (city, c.name, am_sold) city, district, c.name, am_sold
FROM cte c
         JOIN (SELECT name, MAX(am_sold) AS am -- max overall
               FROM cte
               GROUP BY name
               UNION ALL
               SELECT name, MAX(am_sold) AS am -- max in city
               FROM cte
               WHERE city IS NOT NULL
               GROUP BY name
               UNION ALL
               SELECT name, MAX(am_sold) AS am -- max in territory
               FROM cte
               WHERE city IS NOT NULL
                 AND district IS NOT NULL
               GROUP BY name) AS ag
              ON ag.am = c.am_sold AND ag.name = c.name
ORDER BY name, am_sold DESC;

-- Plus sum of all
WITH cte AS (SELECT city, district, name, SUM(amount_sold) AS am_sold
             FROM drug
                      JOIN public.sold ON drug.drug_id = sold.drug_id
                      JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
             GROUP BY GROUPING SETS ((city, district, name), (city, name), (name)))
SELECT DISTINCT ON (city, c.name, am_sold) city,
                                           district,
                                           c.name,
                                           CASE -- Coalesce
                                               WHEN c.name IS NULL
                                                   THEN SUM(CASE
                                                                WHEN c.city IS NULL AND c.district IS NULL THEN am_sold
                                                                ELSE 0 END) OVER ()
                                               ELSE am_sold END
FROM cte c
         RIGHT JOIN (SELECT name, MAX(am_sold) AS am -- max overall
                     FROM cte
                     GROUP BY name
                     UNION ALL
                     SELECT name, MAX(am_sold) AS am -- max in city
                     FROM cte
                     WHERE city IS NOT NULL
                     GROUP BY name
                     UNION ALL
                     SELECT name, MAX(am_sold) AS am -- max in territory
                     FROM cte
                     WHERE city IS NOT NULL
                       AND district IS NOT NULL
                     GROUP BY name
                     UNION ALL
                     SELECT NULL, NULL) AS ag
                    ON ag.am = c.am_sold AND ag.name = c.name
ORDER BY name, am_sold DESC;

-- Multiple joins
WITH cte AS (SELECT city, district, name, SUM(amount_sold) AS am_sold
             FROM drug
                      JOIN public.sold ON drug.drug_id = sold.drug_id
                      JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
             GROUP BY GROUPING SETS ((city, district, name), (city, name), (name)))
-- Possible ROLLUP (name, city, district)
SELECT city,
       district,
       c.name,
       COALESCE(am_sold, SUM(CASE
                                 WHEN c.city IS NULL AND c.district IS NULL THEN am_sold
                                 ELSE 0 END) OVER ()) AS am_sold
FROM cte c
         JOIN (SELECT name, MAX(am_sold) AS am -- max in territory
               FROM cte
               WHERE cte.district IS NOT NULL
                 AND cte.city IS NOT NULL
               GROUP BY name) AS ag
              ON ag.am = c.am_sold AND ag.name = c.name AND district IS NOT NULL AND city IS NOT NULL
UNION ALL
-- All data are unique -> to optimize by not removing non existent duplicate rows
SELECT city, district, c.name, am_sold
FROM cte c
         JOIN (SELECT name, MAX(am_sold) AS am -- max in city
               FROM cte
               WHERE cte.district IS NULL
                 AND cte.city IS NOT NULL
               GROUP BY name) AS ag ON ag.am = c.am_sold AND ag.name = c.name AND district IS NULL AND city IS NOT NULL
UNION ALL
-- All data are unique -> to optimize by not removing non existent duplicate rows
SELECT city, district, c.name, am_sold
FROM cte c
         JOIN (SELECT name, MAX(am_sold) AS am -- max overall
               FROM cte
               GROUP BY name) AS ag ON ag.am = c.am_sold AND ag.name = c.name
UNION ALL
SELECT NULL, NULL, NULL, SUM(ag.am) -- sum of all
FROM (SELECT name, MAX(am_sold) AS am -- max overall
      FROM cte
      GROUP BY name) as ag
ORDER BY name, am_sold DESC;