-- Jednoduchy dotaz
SELECT film.nazev
FROM kino
         JOIN formama9.sal ON kino.id_kino = sal.id_kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
WHERE mesto = 'Praha '
  AND film.nazev IN (SELECT film.nazev
                     FROM film
                              JOIN formama9.reziser ON reziser.id_rezisera = film.id_rezisera
                              JOIN formama9.umelec ON reziser.id_rezisera = umelec.id_umelce
                              JOIN formama9.zeme ON zeme.zeme_kod = umelec.zeme_kod
                     WHERE zeme.nazev NOT IN ('Česká republika', 'Československo'))
UNION
SELECT film.nazev
FROM kino
         JOIN formama9.sal ON kino.id_kino = sal.id_kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
WHERE sal.vybaveni = 'Dolby audio systém'
  AND EXISTS(SELECT 1
             FROM film f
             WHERE film.rok < f.rok
               AND f.nazev = 'Válka Bohů');

-- Optimalizator refactor
SELECT film.nazev
FROM kino
         JOIN formama9.sal ON kino.id_kino = sal.id_kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.reziser ON reziser.id_rezisera = film.id_rezisera
         JOIN formama9.umelec ON reziser.id_rezisera = umelec.id_umelce
         JOIN formama9.zeme ON zeme.zeme_kod = umelec.zeme_kod
WHERE mesto = 'Praha '
  AND zeme.nazev <> 'Česká republika'
  AND zeme.nazev <> 'Československo'
UNION
SELECT film.nazev
FROM kino
         JOIN formama9.sal ON kino.id_kino = sal.id_kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
WHERE sal.vybaveni = 'Dolby audio systém'
  AND rok < (SELECT rok FROM film f WHERE f.nazev = 'Válka Bohů');

-- Bez UNION
SELECT DISTINCT film.nazev
FROM kino
         JOIN formama9.sal ON kino.id_kino = sal.id_kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.reziser ON reziser.id_rezisera = film.id_rezisera
         JOIN formama9.umelec ON reziser.id_rezisera = umelec.id_umelce
         JOIN formama9.zeme ON zeme.zeme_kod = umelec.zeme_kod
WHERE (mesto = 'Praha '
    AND zeme.nazev <> 'Česká republika'
    AND zeme.nazev <> 'Československo')
   OR (sal.vybaveni = 'Dolby audio systém' AND film.rok < (SELECT rok FROM film f WHERE f.nazev = 'Válka Bohů'));

-- Pridani indexu
CREATE INDEX kino_mesto_idx on kino (mesto);
CREATE INDEX zeme_nazev_idx on zeme (nazev);
CREATE INDEX film_nazev_idx on film (nazev);
CREATE INDEX sal_vybaveni_idx on sal (vybaveni);

SELECT DISTINCT film.nazev
FROM kino
         JOIN formama9.sal ON kino.id_kino = sal.id_kino
         JOIN formama9.predstaveni ON kino.id_kino = predstaveni.id_kino
         JOIN formama9.film ON film.id_filmu = predstaveni.id_filmu
         JOIN formama9.reziser ON reziser.id_rezisera = film.id_rezisera
         JOIN formama9.umelec ON reziser.id_rezisera = umelec.id_umelce
         JOIN formama9.zeme ON zeme.zeme_kod = umelec.zeme_kod
WHERE (mesto = 'Praha '
    AND zeme.nazev <> 'Česká republika'
    AND zeme.nazev <> 'Československo')
   OR (sal.vybaveni = 'Dolby audio systém' AND film.rok < (SELECT rok FROM film f WHERE f.nazev = 'Válka Bohů'));