-- Jednoduchy
SELECT nazev_koreni, COUNT(nazev_koreni) ct
FROM koreni
         JOIN produkt_koreni pk ON koreni.id_koreni = pk.id_koreni
GROUP BY nazev_koreni
HAVING COUNT(nazev_koreni) = (SELECT MAX(ct)
                              FROM (SELECT nazev_koreni, COUNT(nazev_koreni) ct
                                    FROM koreni
                                             JOIN produkt_koreni pk ON koreni.id_koreni = pk.id_koreni
                                    GROUP BY nazev_koreni) AS nkc);

-- With CTE
WITH mts AS (SELECT nazev_koreni, COUNT(nazev_koreni) ct
             FROM koreni
                      JOIN produkt_koreni pk ON koreni.id_koreni = pk.id_koreni
             GROUP BY nazev_koreni)
SELECT *
FROM mts
WHERE ct = (SELECT MAX(ct) FROM mts);

-- 2x Volat VIEW
CREATE OR REPLACE VIEW multispice AS
SELECT nazev_koreni, COUNT(nazev_koreni) ct
FROM koreni
         JOIN produkt_koreni pk ON koreni.id_koreni = pk.id_koreni
GROUP BY nazev_koreni;


SELECT multispice.nazev_koreni, multispice.ct
FROM multispice
WHERE ct = (SELECT MAX(ct) FROM multispice);

-- Materialized view
CREATE MATERIALIZED VIEW mat_multispice AS
SELECT nazev_koreni, COUNT(nazev_koreni) ct
FROM koreni
         JOIN produkt_koreni pk ON koreni.id_koreni = pk.id_koreni
GROUP BY nazev_koreni
ORDER BY COUNT(nazev_koreni) DESC;

SELECT nazev_koreni, ct
FROM mat_multispice
LIMIT 1;