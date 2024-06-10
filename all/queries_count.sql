-- kino ktery hralo vsechny ceske a ceskoslovenske filmy ale jen a pouze tyto
-- Basic
SELECT kino.nazev
FROM kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
         JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
WHERE zeme.nazev = 'Československo'
GROUP BY kino.nazev
HAVING COUNT(zeme.nazev) = (SELECT COUNT(*)
                            FROM zeme
                                     JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                            WHERE zeme.nazev = 'Československo')
UNION
SELECT kino.nazev
FROM kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
         JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
WHERE zeme.nazev = 'Česká republika'
GROUP BY kino.nazev
HAVING COUNT(zeme.nazev) = (SELECT COUNT(*)
                            FROM zeme
                                     JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                            WHERE zeme.nazev = 'Česká republika')
MINUS
SELECT kino.nazev
FROM kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
         JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
WHERE zeme.nazev <> 'Česká republika'
  AND zeme.nazev <> 'Československo';

-- With CTE
WITH cte AS (SELECT kino.nazev AS kin, zeme.nazev AS zem
             FROM kino
                      JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
                      JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
                      JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
                      JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod),
     cz AS (SELECT kin
            FROM cte
            WHERE zem = 'Česká republika'
            GROUP BY kin
            HAVING COUNT(zem) = (SELECT COUNT(*)
                                 FROM zeme
                                          JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                                 WHERE zeme.nazev = 'Česká republika')),
     csr AS (SELECT kin
             FROM cte
             WHERE zem = 'Československo'
             GROUP BY kin
             HAVING COUNT(zem) = (SELECT COUNT(*)
                                  FROM zeme
                                           JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                                  WHERE zeme.nazev = 'Československo')),
     min AS (SELECT kin
             FROM cte
             WHERE zem <> 'Česká republika'
               AND zem <> 'Československo')
SELECT *
FROM cz
UNION
SELECT *
FROM csr
MINUS
SELECT *
FROM min;

-- Optimized (works because we want only these 2 types of movies)
SELECT kino.nazev
FROM kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
         JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
WHERE zeme.nazev = 'Československo'
   OR zeme.nazev = 'Česká republika'
GROUP BY kino.nazev
HAVING COUNT(zeme.nazev) = (SELECT COUNT(*)
                            FROM zeme
                                     JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                            WHERE zeme.nazev = 'Československo'
                               OR zeme.nazev = 'Česká republika');