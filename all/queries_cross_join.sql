-- kino ktery hralo vsechny ceske a ceskoslovenske filmy ale jen a pouze tyto
SELECT DISTINCT kino.nazev -- vsechna kina
FROM kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
         JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
WHERE kino.nazev NOT IN (SELECT kin -- vyber kina kterym zbylo moznost jeste hrat nejaky CZ nebo CSR film
                         FROM (SELECT kino.nazev AS kin,
                                      film.nazev,
                                      zeme.nazev AS zem -- vsechny moznosti co kina by mohla hrat
                               FROM kino
                                        CROSS JOIN film
                                        JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
                                        JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                               MINUS
                               SELECT kino.nazev AS kin,
                                      film.nazev,
                                      zeme.nazev AS zem -- vsechna kina co hraji CZ || CSR filmy
                               FROM kino
                                        JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
                                        JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
                                        JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
                                        JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                               WHERE zeme.nazev = 'Československo'
                                  OR zeme.nazev = 'Česká republika') grp
                         WHERE zem = 'Československo'
                            OR zem = 'Česká republika')
  AND kino.nazev NOT IN (SELECT kino.nazev -- Odecti kina co hraji i neco jineho
                         FROM kino
                                  JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
                                  JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
                                  JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
                                  JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                         WHERE zeme.nazev <> 'Česká republika'
                           AND zeme.nazev <> 'Československo');

-- Set operator MINUS
SELECT kino.nazev -- vsechna kina
FROM kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
         JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
MINUS
SELECT kin -- vyber kina kterym zbylo moznost jeste hrat nejaky CZ nebo CSR film
FROM (SELECT kino.nazev AS kin, film.nazev, zeme.nazev AS zem -- vsechny moznosti co kina by mohla hrat
      FROM kino
               CROSS JOIN film
               JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
               JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
      MINUS
      SELECT kino.nazev AS kin, film.nazev, zeme.nazev AS zem -- vsechna kina co hraji CZ || CSR filmy
      FROM kino
               JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
               JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
               JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
               JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
      WHERE zeme.nazev = 'Československo'
         OR zeme.nazev = 'Česká republika') grp
WHERE zem = 'Československo'
   OR zem = 'Česká republika'
MINUS
SELECT kino.nazev -- Odecti kina co hraji i neco jineho
FROM kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
         JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
WHERE zeme.nazev <> 'Česká republika'
  AND zeme.nazev <> 'Československo';

-- With CTE
WITH cte AS (SELECT kino.nazev AS kin, film.nazev AS fim, zeme.nazev AS zem
             FROM kino
                      JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
                      JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
                      JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
                      JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod)
SELECT kin -- vsechna kina
FROM cte
MINUS
SELECT kin -- vyber kina kterym zbylo moznost jeste hrat nejaky CZ nebo CSR film
FROM (SELECT kino.nazev AS kin, film.nazev, zeme.nazev AS zem -- vsechny moznosti co kina by mohla hrat
      FROM kino
               CROSS JOIN film
               JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
               JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
      MINUS
      SELECT kin, fim, zem -- vsechna kina co hraji CZ || CSR filmy
      FROM cte
      WHERE zem = 'Československo'
         OR zem = 'Česká republika') grp
WHERE zem = 'Československo'
   OR zem = 'Česká republika'
MINUS
SELECT kin -- Odecti kina co hraji i neco jineho
FROM cte
WHERE zem <> 'Česká republika'
  AND zem <> 'Československo';