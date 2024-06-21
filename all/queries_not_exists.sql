-- kino ktery hralo vsechny ceske a ceskoslovenske filmy ale jen a pouze tyto

-- najdi kino kde neexistuje CZ ci CSR  film ktery by nebyl na jeho programu
SELECT nazev
FROM kino k
WHERE NOT EXISTS(SELECT 1
                 FROM zeme
                          JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                          JOIN formama9.film f ON f.id_filmu = film_zeme.id_filmu
                 WHERE zeme.nazev = 'Československo'
                   AND f.nazev NOT IN (SELECT film.nazev
                                       FROM film
                                                JOIN formama9.predstaveni ON film.id_filmu = predstaveni.id_filmu
                                                JOIN formama9.kino ON predstaveni.id_kino = k.id_kino))
INTERSECT
SELECT nazev
FROM kino k
WHERE NOT EXISTS(SELECT 1
                 FROM zeme
                          JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                          JOIN formama9.film f ON f.id_filmu = film_zeme.id_filmu
                 WHERE zeme.nazev = 'Česká republika'
                   AND f.nazev NOT IN (SELECT film.nazev
                                       FROM film
                                                JOIN formama9.predstaveni ON film.id_filmu = predstaveni.id_filmu
                                                JOIN formama9.kino ON predstaveni.id_kino = k.id_kino))
MINUS
SELECT kino.nazev -- Odecti kina co hraji i neco jineho
FROM kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
         JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
WHERE zeme.nazev <> 'Česká republika'
  AND zeme.nazev <> 'Československo';

-- najdi kino kde neexistuje cz a zaroven csr film ktery by nebyl na programu
-- Logic instead of INTERSECT
SELECT nazev
FROM kino k
WHERE NOT EXISTS(SELECT 1
                 FROM zeme
                          JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                          JOIN formama9.film f ON f.id_filmu = film_zeme.id_filmu
                 WHERE (zeme.nazev = 'Československo' OR zeme.nazev = 'Česká republika')
                   AND f.nazev NOT IN (SELECT film.nazev
                                       FROM film
                                                JOIN formama9.predstaveni ON film.id_filmu = predstaveni.id_filmu
                                                JOIN formama9.kino ON predstaveni.id_kino = k.id_kino))
MINUS
SELECT kino.nazev -- Odecti kina co hraji i neco jineho
FROM kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
         JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
WHERE zeme.nazev <> 'Česká republika'
  AND zeme.nazev <> 'Československo';

-- najdi kino kde neexistuje cz a zaroven csr film ktery by nebyl na programu
-- no MINUS
SELECT k.nazev
FROM kino k
WHERE NOT EXISTS(SELECT 1
                 FROM zeme
                          JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                          JOIN formama9.film f ON f.id_filmu = film_zeme.id_filmu
                 WHERE (zeme.nazev = 'Československo' OR zeme.nazev = 'Česká republika')
                   AND f.nazev NOT IN (SELECT film.nazev
                                       FROM film
                                                JOIN formama9.predstaveni ON film.id_filmu = predstaveni.id_filmu
                                                JOIN formama9.kino ON predstaveni.id_kino = k.id_kino))
  AND k.nazev NOT IN (SELECT kino.nazev
                      FROM kino
                               JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
                               JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
                               JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
                               JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                      WHERE zeme.nazev <> 'Česká republika'
                        AND zeme.nazev <> 'Československo');

-- NOT IN to LEFT JOIN
SELECT k.nazev
FROM kino k
         LEFT JOIN (SELECT kino.nazev
                    FROM kino
                             JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
                             JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
                             JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
                             JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                    WHERE zeme.nazev <> 'Česká republika'
                      AND zeme.nazev <> 'Československo') valid_kino ON valid_kino.nazev = k.nazev
WHERE NOT EXISTS(SELECT 1
                 FROM zeme
                          JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                          JOIN formama9.film f ON f.id_filmu = film_zeme.id_filmu
                          LEFT JOIN (SELECT film.nazev
                                     FROM film
                                              JOIN formama9.predstaveni ON film.id_filmu = predstaveni.id_filmu
                                              JOIN formama9.kino ON predstaveni.id_kino = k.id_kino) not_in_join ON
                     not_in_join.nazev = f.nazev
                 WHERE (zeme.nazev = 'Československo' OR zeme.nazev = 'Česká republika')
                   AND not_in_join.nazev IS NULL)
  AND valid_kino.nazev IS NULL;

SELECT DISTINCT k.nazev
FROM kino k
         LEFT JOIN (SELECT kino.nazev -- kina co hrali pouze CZ a CSR filmy
                    FROM kino
                             JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
                             JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
                             JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
                             JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                    WHERE zeme.nazev <> 'Česká republika'
                      AND zeme.nazev <> 'Československo') valid_kino ON valid_kino.nazev = k.nazev
         LEFT JOIN (SELECT zeme.nazev AS zn, not_in_join.nazev AS nij, not_in_join.pid AS nipd -- kina co hraji vsechny CZ A CSR filmy
                    FROM zeme
                             JOIN formama9.film_zeme ON zeme.zeme_kod = film_zeme.zeme_kod
                             JOIN formama9.film f ON f.id_filmu = film_zeme.id_filmu
                             LEFT JOIN (SELECT predstaveni.id_kino AS pid, film.nazev
                                        FROM film
                                                 JOIN formama9.predstaveni ON film.id_filmu = predstaveni.id_filmu) not_in_join
                                       ON not_in_join.nazev = f.nazev) not_exists
                   ON (not_exists.zn = 'Československo' OR not_exists.zn = 'Česká republika')
                       AND not_exists.nipd is NULL
                       AND not_exists.nij IS NULL
         JOIN predstaveni ON k.id_kino = predstaveni.id_kino -- odeber kino co nikdy nic nehralo
WHERE valid_kino.nazev IS NULL;