-- Insert script
INSERT INTO kino (id_kino, nazev, mesto, ulice, cislo_popisne, cislo_orientacni, psc)
VALUES (16, 'Westfield Chodov', 'Praha ', 'partyzanu', 666, 420, 25101);
INSERT INTO kino (id_kino, nazev, mesto, ulice, cislo_popisne, cislo_orientacni, psc)
VALUES (17, 'Galaxie Haje', 'Praha ', 'partyzanu', 666, 420, 25101);

-- kino with no connections
INSERT INTO kino (id_kino, nazev, mesto, ulice, cislo_popisne, cislo_orientacni, psc)
VALUES (18, 'Ricany Na Fialce', 'Ricany', 'taborksa', 666, 420, 25101);

INSERT INTO sal (id_kino, cislo, kapacita, vybaveni)
VALUES (16, 1, 90, 'Dolby audio systém');
INSERT INTO sal (id_kino, cislo, kapacita, vybaveni)
VALUES (17, 1, 90, 'Dolby audio systém');

-- give them all CZ and CSR movies
DECLARE
    pred INTEGER := 51;
BEGIN
    FOR i IN
        (SELECT DISTINCT film.nazev, film_zeme.id_filmu
         FROM film
                  JOIN formama9.film_zeme ON film.id_filmu = film_zeme.id_filmu
                  JOIN formama9.zeme ON zeme.zeme_kod = film_zeme.zeme_kod
         WHERE zeme.nazev = 'Československo'
            OR zeme.nazev = 'Česká republika'
         ORDER BY id_filmu)
        LOOP
            INSERT INTO predstaveni (id_kino, cislo, id_filmu, id_predstaveni, datum_a_cas)
            VALUES (16, 1, i.id_filmu, pred, SYSDATE);
            pred := pred + 1;
            INSERT INTO predstaveni (id_kino, cislo, id_filmu, id_predstaveni, datum_a_cas)
            VALUES (17, 1, i.id_filmu, pred, SYSDATE);
            pred := pred + 1;
        END LOOP;
    COMMIT;
END;

-- change structure of one special movie
UPDATE film_zeme
SET id_filmu = 26
WHERE id_filmu = 9
  AND zeme_kod <> 'CZE';

-- make sure that 17 - Galaxie Haje has all cz and csr but not only that
INSERT INTO predstaveni (id_kino, cislo, id_filmu, id_predstaveni, datum_a_cas)
VALUES (17, 1, 26, 70, SYSDATE);
