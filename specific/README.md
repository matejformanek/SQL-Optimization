# Filmy hrane v praze ktere nejsou od ceskeho rezisera a soucasne filmy hrane v salech s dolby audio systemem vydane pred filmem Valka bohu (Oracle)

Na schematu z testoveho zadani si zkusime vytvorit specialne vyfiltrovany dotaz ktery vraci filmy pro prazske publikum
co nema rado ceske filmy ale pro dolby atmos je ochotno zkusit libovolny film kdekoli s podminkou ze je starsi nez film
Valka bohu. Budeme se snazit postupne upravovat jednoduchy "Naivni SELECT" a nakonci pripadne pridat i INDEXY (data jsou
velmi mala takze nebude ukazan jejich vyhoda naplno).

## Schema - Multikina

![alt text](multikina.png)

## Dotazy

### 1) Jednoduchy dotaz

UNION se EXISTS a IN strukturou pro specificky vyber.

```sql
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
```

### Plan

```
Plan hash value: 3128870651
 
---------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |             |    28 |  2376 |    35  (18)| 00:00:01 |
|   1 |  SORT UNIQUE                        |             |    28 |  2376 |    35  (18)| 00:00:01 |
|   2 |   UNION-ALL                         |             |       |       |            |          |
|*  3 |    HASH JOIN SEMI                   |             |    12 |  1032 |    19   (6)| 00:00:01 |
|*  4 |     HASH JOIN SEMI                  |             |    12 |   996 |    18   (6)| 00:00:01 |
|*  5 |      HASH JOIN                      |             |    13 |   884 |    15   (7)| 00:00:01 |
|*  6 |       HASH JOIN                     |             |    13 |   793 |    12   (9)| 00:00:01 |
|*  7 |        HASH JOIN                    |             |    13 |   520 |     9  (12)| 00:00:01 |
|   8 |         MERGE JOIN                  |             |    13 |   247 |     6  (17)| 00:00:01 |
|*  9 |          TABLE ACCESS BY INDEX ROWID| KINO        |     4 |    52 |     2   (0)| 00:00:01 |
|  10 |           INDEX FULL SCAN           | Kino PK     |    15 |       |     1   (0)| 00:00:01 |
|* 11 |          SORT JOIN                  |             |    50 |   300 |     4  (25)| 00:00:01 |
|  12 |           TABLE ACCESS FULL         | PREDSTAVENI |    50 |   300 |     3   (0)| 00:00:01 |
|  13 |         TABLE ACCESS FULL           | FILM        |    30 |   630 |     3   (0)| 00:00:01 |
|* 14 |        TABLE ACCESS FULL            | FILM        |    30 |   630 |     3   (0)| 00:00:01 |
|  15 |       TABLE ACCESS FULL             | UMELEC      |    48 |   336 |     3   (0)| 00:00:01 |
|* 16 |      TABLE ACCESS FULL              | ZEME        |    14 |   210 |     3   (0)| 00:00:01 |
|  17 |     INDEX FULL SCAN                 | PK_SAL      |   114 |   342 |     1   (0)| 00:00:01 |
|  18 |    MERGE JOIN SEMI                  |             |    16 |  1344 |    14  (22)| 00:00:01 |
|  19 |     SORT JOIN                       |             |    35 |  2170 |    10  (20)| 00:00:01 |
|* 20 |      HASH JOIN SEMI                 |             |    35 |  2170 |     9  (12)| 00:00:01 |
|  21 |       MERGE JOIN                    |             |    50 |  1550 |     6  (17)| 00:00:01 |
|  22 |        TABLE ACCESS BY INDEX ROWID  | FILM        |    30 |   750 |     2   (0)| 00:00:01 |
|  23 |         INDEX FULL SCAN             | film PK     |    30 |       |     1   (0)| 00:00:01 |
|* 24 |        SORT JOIN                    |             |    50 |   300 |     4  (25)| 00:00:01 |
|  25 |         TABLE ACCESS FULL           | PREDSTAVENI |    50 |   300 |     3   (0)| 00:00:01 |
|* 26 |       TABLE ACCESS FULL             | SAL         |    10 |   310 |     3   (0)| 00:00:01 |
|* 27 |     SORT UNIQUE                     |             |     1 |    22 |     4  (25)| 00:00:01 |
|* 28 |      TABLE ACCESS FULL              | FILM        |     1 |    22 |     3   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   3 - access(""KINO"".""ID_KINO""=""SAL"".""ID_KINO"")"
"   4 - access(""ZEME"".""ZEME_KOD""=""UMELEC"".""ZEME_KOD"")"
"   5 - access(""FILM"".""ID_REZISERA""=""UMELEC"".""ID_UMELCE"")"
"   6 - access(""FILM"".""NAZEV""=""FILM"".""NAZEV"")"
"   7 - access(""FILM"".""ID_FILMU""=""PREDSTAVENI"".""ID_FILMU"")"
"   9 - filter(""KINO"".""MESTO""='Praha ')"
"  11 - access(""KINO"".""ID_KINO""=""PREDSTAVENI"".""ID_KINO"")"
"       filter(""KINO"".""ID_KINO""=""PREDSTAVENI"".""ID_KINO"")"
"  14 - filter(""FILM"".""ID_REZISERA"" IS NOT NULL)"
"  16 - filter(""ZEME"".""NAZEV""<>'Česká republika' AND ""ZEME"".""NAZEV""<>'Československo')"
"  20 - access(""SAL"".""ID_KINO""=""PREDSTAVENI"".""ID_KINO"")"
"  24 - access(""FILM"".""ID_FILMU""=""PREDSTAVENI"".""ID_FILMU"")"
"       filter(""FILM"".""ID_FILMU""=""PREDSTAVENI"".""ID_FILMU"")"
"  26 - filter(""SAL"".""VYBAVENI""='Dolby audio systém')"
"  27 - access(""FILM"".""ROK""<""F"".""ROK"")"
"       filter(""FILM"".""ROK""<""F"".""ROK"")"
"  28 - filter(""F"".""NAZEV""='Válka Bohů')"
```

### Vysledek

```
Nazev (15 rows)
---------------------------------------------------------------------
Antikrist
Havran
Hollywood v koncích
Jeden musí z kola ven
Lítám v tom
Musíme si promluvit o Kevinovi
Na samotě u lesa
Poznáš muže svých snů
Pretty Woman
Pátý element
Sněhurka
V jako Vendeta 
Válka Bohů
Věčný svit neposkvrněné mysli
Černá labuť
```

Vraci spravny vysledek, ale je to pomale a mnoho veci lze prepsat podle toho jak nam radi optimalizator.

### 2) Optimalizator refactor

```sql
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
```

### Plan

```
Plan hash value: 299457497
 
--------------------------------------------------------------------------------------------------
| Id  | Operation                          | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                   |             |    14 |   940 |    30  (14)| 00:00:01 |
|   1 |  SORT UNIQUE                       |             |    14 |   940 |    30  (14)| 00:00:01 |
|   2 |   UNION-ALL                        |             |       |       |            |          |
|*  3 |    HASH JOIN SEMI                  |             |    12 |   816 |    16   (7)| 00:00:01 |
|*  4 |     HASH JOIN SEMI                 |             |    12 |   780 |    15   (7)| 00:00:01 |
|*  5 |      HASH JOIN                     |             |    13 |   650 |    12   (9)| 00:00:01 |
|*  6 |       HASH JOIN                    |             |    13 |   559 |     9  (12)| 00:00:01 |
|   7 |        MERGE JOIN                  |             |    13 |   247 |     6  (17)| 00:00:01 |
|*  8 |         TABLE ACCESS BY INDEX ROWID| KINO        |     4 |    52 |     2   (0)| 00:00:01 |
|   9 |          INDEX FULL SCAN           | Kino PK     |    15 |       |     1   (0)| 00:00:01 |
|* 10 |         SORT JOIN                  |             |    50 |   300 |     4  (25)| 00:00:01 |
|  11 |          TABLE ACCESS FULL         | PREDSTAVENI |    50 |   300 |     3   (0)| 00:00:01 |
|* 12 |        TABLE ACCESS FULL           | FILM        |    30 |   720 |     3   (0)| 00:00:01 |
|  13 |       TABLE ACCESS FULL            | UMELEC      |    48 |   336 |     3   (0)| 00:00:01 |
|* 14 |      TABLE ACCESS FULL             | ZEME        |    14 |   210 |     3   (0)| 00:00:01 |
|  15 |     INDEX FULL SCAN                | PK_SAL      |   114 |   342 |     1   (0)| 00:00:01 |
|* 16 |    HASH JOIN SEMI                  |             |     2 |   124 |     9  (12)| 00:00:01 |
|  17 |     MERGE JOIN                     |             |     3 |    93 |     6  (17)| 00:00:01 |
|* 18 |      TABLE ACCESS BY INDEX ROWID   | FILM        |     2 |    50 |     2   (0)| 00:00:01 |
|  19 |       INDEX FULL SCAN              | film PK     |    30 |       |     1   (0)| 00:00:01 |
|* 20 |       TABLE ACCESS FULL            | FILM        |     1 |    22 |     3   (0)| 00:00:01 |
|* 21 |      SORT JOIN                     |             |    50 |   300 |     4  (25)| 00:00:01 |
|  22 |       TABLE ACCESS FULL            | PREDSTAVENI |    50 |   300 |     3   (0)| 00:00:01 |
|* 23 |     TABLE ACCESS FULL              | SAL         |    10 |   310 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   3 - access(""KINO"".""ID_KINO""=""SAL"".""ID_KINO"")"
"   4 - access(""ZEME"".""ZEME_KOD""=""UMELEC"".""ZEME_KOD"")"
"   5 - access(""FILM"".""ID_REZISERA""=""UMELEC"".""ID_UMELCE"")"
"   6 - access(""FILM"".""ID_FILMU""=""PREDSTAVENI"".""ID_FILMU"")"
"   8 - filter(""KINO"".""MESTO""='Praha ')"
"  10 - access(""KINO"".""ID_KINO""=""PREDSTAVENI"".""ID_KINO"")"
"       filter(""KINO"".""ID_KINO""=""PREDSTAVENI"".""ID_KINO"")"
"  12 - filter(""FILM"".""ID_REZISERA"" IS NOT NULL)"
"  14 - filter(""ZEME"".""NAZEV""<>'Česká republika' AND ""ZEME"".""NAZEV""<>'Československo')"
"  16 - access(""SAL"".""ID_KINO""=""PREDSTAVENI"".""ID_KINO"")"
"  18 - filter(""FILM"".""ROK""< (SELECT ""ROK"" FROM ""FILM"" ""F"" WHERE ""F"".""NAZEV""='Válka Bohů'))"
"  20 - filter(""F"".""NAZEV""='Válka Bohů')"
"  21 - access(""FILM"".""ID_FILMU""=""PREDSTAVENI"".""ID_FILMU"")"
"       filter(""FILM"".""ID_FILMU""=""PREDSTAVENI"".""ID_FILMU"")"
"  23 - filter(""SAL"".""VYBAVENI""='Dolby audio systém')"

```

### Vysledek

```
Nazev (15 rows)
---------------------------------------------------------------------
Antikrist
Havran
Hollywood v koncích
Jeden musí z kola ven
Lítám v tom
Musíme si promluvit o Kevinovi
Na samotě u lesa
Poznáš muže svých snů
Pretty Woman
Pátý element
Sněhurka
V jako Vendeta 
Válka Bohů
Věčný svit neposkvrněné mysli
Černá labuť
```

Vysledek identicky. Zmeny u prvniho SELECTU jsme dle funkce optimalizatoru zmenili IN na join a NOT IN na dva AND. Male zrychleni dostavame diky druhemu SELECTU kde misto EXISTS pouzivame lepsi konstrukci na hledani mensiho roku nez je dany film.

### 3) Bez UNION

```sql
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
```

### Plan

```
Plan hash value: 75112611
 
-------------------------------------------------------------------------------------------------
| Id  | Operation                         | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                  |             |    30 |  3000 |    19  (11)| 00:00:01 |
|   1 |  HASH UNIQUE                      |             |    30 |  3000 |    19  (11)| 00:00:01 |
|*  2 |   HASH JOIN                       |             |    32 |  3200 |    18   (6)| 00:00:01 |
|*  3 |    HASH JOIN                      |             |    50 |  3450 |    15   (7)| 00:00:01 |
|*  4 |     HASH JOIN                     |             |    50 |  2800 |    12   (9)| 00:00:01 |
|*  5 |      HASH JOIN                    |             |    30 |  1500 |     9  (12)| 00:00:01 |
|   6 |       MERGE JOIN                  |             |    48 |  1056 |     6  (17)| 00:00:01 |
|   7 |        TABLE ACCESS BY INDEX ROWID| ZEME        |    16 |   240 |     2   (0)| 00:00:01 |
|   8 |         INDEX FULL SCAN           | zeme PK     |    16 |       |     1   (0)| 00:00:01 |
|*  9 |        SORT JOIN                  |             |    48 |   336 |     4  (25)| 00:00:01 |
|  10 |         TABLE ACCESS FULL         | UMELEC      |    48 |   336 |     3   (0)| 00:00:01 |
|* 11 |       TABLE ACCESS FULL           | FILM        |    30 |   840 |     3   (0)| 00:00:01 |
|  12 |      TABLE ACCESS FULL            | PREDSTAVENI |    50 |   300 |     3   (0)| 00:00:01 |
|  13 |     TABLE ACCESS FULL             | KINO        |    15 |   195 |     3   (0)| 00:00:01 |
|  14 |    TABLE ACCESS FULL              | SAL         |   114 |  3534 |     3   (0)| 00:00:01 |
|* 15 |    TABLE ACCESS FULL              | FILM        |     1 |    22 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   2 - access(""KINO"".""ID_KINO""=""SAL"".""ID_KINO"")"
"       filter(""KINO"".""MESTO""='Praha ' AND ""ZEME"".""NAZEV""<>'Česká republika' AND "
"              ""ZEME"".""NAZEV""<>'Československo' OR ""SAL"".""VYBAVENI""='Dolby audio systém' AND "
"              ""FILM"".""ROK""< (SELECT ""ROK"" FROM ""FILM"" ""F"" WHERE ""F"".""NAZEV""='Válka Bohů'))"
"   3 - access(""KINO"".""ID_KINO""=""PREDSTAVENI"".""ID_KINO"")"
"   4 - access(""FILM"".""ID_FILMU""=""PREDSTAVENI"".""ID_FILMU"")"
"   5 - access(""FILM"".""ID_REZISERA""=""UMELEC"".""ID_UMELCE"")"
"   9 - access(""ZEME"".""ZEME_KOD""=""UMELEC"".""ZEME_KOD"")"
"       filter(""ZEME"".""ZEME_KOD""=""UMELEC"".""ZEME_KOD"")"
"  11 - filter(""FILM"".""ID_REZISERA"" IS NOT NULL)"
"  15 - filter(""F"".""NAZEV""='Válka Bohů')"
```

### Vysledek

```
Nazev (15 rows)
---------------------------------------------------------------------
Antikrist
Havran
Hollywood v koncích
Jeden musí z kola ven
Lítám v tom
Musíme si promluvit o Kevinovi
Na samotě u lesa
Poznáš muže svých snů
Pretty Woman
Pátý element
Sněhurka
V jako Vendeta 
Válka Bohů
Věčný svit neposkvrněné mysli
Černá labuť
```

Temer dvojnasobne zrychleni diky vyrokove logice ve WHERE namisto drahemu UNION.

### 4) Pridani indexu

```sql
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
```

### Plan

```
Plan hash value: 2716291903
 
----------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                  |    30 |  3000 |    17  (12)| 00:00:01 |
|   1 |  HASH UNIQUE                          |                  |    30 |  3000 |    17  (12)| 00:00:01 |
|*  2 |   HASH JOIN                           |                  |    32 |  3200 |    16   (7)| 00:00:01 |
|*  3 |    HASH JOIN                          |                  |    50 |  3450 |    13   (8)| 00:00:01 |
|*  4 |     HASH JOIN                         |                  |    50 |  2800 |    11  (10)| 00:00:01 |
|*  5 |      HASH JOIN                        |                  |    50 |  2050 |     9  (12)| 00:00:01 |
|   6 |       MERGE JOIN                      |                  |    50 |  1700 |     6  (17)| 00:00:01 |
|*  7 |        TABLE ACCESS BY INDEX ROWID    | FILM             |    30 |   840 |     2   (0)| 00:00:01 |
|   8 |         INDEX FULL SCAN               | film PK          |    30 |       |     1   (0)| 00:00:01 |
|*  9 |        SORT JOIN                      |                  |    50 |   300 |     4  (25)| 00:00:01 |
|  10 |         TABLE ACCESS FULL             | PREDSTAVENI      |    50 |   300 |     3   (0)| 00:00:01 |
|  11 |       TABLE ACCESS FULL               | UMELEC           |    48 |   336 |     3   (0)| 00:00:01 |
|  12 |      VIEW                             | index$_join$_012 |    16 |   240 |     2   (0)| 00:00:01 |
|* 13 |       HASH JOIN                       |                  |       |       |            |          |
|  14 |        INDEX FAST FULL SCAN           | ZEME_NAZEV_IDX   |    16 |   240 |     1   (0)| 00:00:01 |
|  15 |        INDEX FAST FULL SCAN           | zeme PK          |    16 |   240 |     1   (0)| 00:00:01 |
|  16 |     VIEW                              | index$_join$_001 |    15 |   195 |     2   (0)| 00:00:01 |
|* 17 |      HASH JOIN                        |                  |       |       |            |          |
|  18 |       INDEX FAST FULL SCAN            | KINO_MESTO_IDX   |    15 |   195 |     1   (0)| 00:00:01 |
|  19 |       INDEX FAST FULL SCAN            | Kino PK          |    15 |   195 |     1   (0)| 00:00:01 |
|  20 |    TABLE ACCESS FULL                  | SAL              |   114 |  3534 |     3   (0)| 00:00:01 |
|  21 |    TABLE ACCESS BY INDEX ROWID BATCHED| FILM             |     1 |    22 |     2   (0)| 00:00:01 |
|* 22 |     INDEX RANGE SCAN                  | FILM_NAZEV_IDX   |     1 |       |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
"   2 - access(""KINO"".""ID_KINO""=""SAL"".""ID_KINO"")"
"       filter(""KINO"".""MESTO""='Praha ' AND ""ZEME"".""NAZEV""<>'Česká republika' AND "
"              ""ZEME"".""NAZEV""<>'Československo' OR ""SAL"".""VYBAVENI""='Dolby audio systém' AND ""FILM"".""ROK""< "
"              (SELECT ""ROK"" FROM ""FILM"" ""F"" WHERE ""F"".""NAZEV""='Válka Bohů'))"
"   3 - access(""KINO"".""ID_KINO""=""PREDSTAVENI"".""ID_KINO"")"
"   4 - access(""ZEME"".""ZEME_KOD""=""UMELEC"".""ZEME_KOD"")"
"   5 - access(""FILM"".""ID_REZISERA""=""UMELEC"".""ID_UMELCE"")"
"   7 - filter(""FILM"".""ID_REZISERA"" IS NOT NULL)"
"   9 - access(""FILM"".""ID_FILMU""=""PREDSTAVENI"".""ID_FILMU"")"
"       filter(""FILM"".""ID_FILMU""=""PREDSTAVENI"".""ID_FILMU"")"
  13 - access(ROWID=ROWID)
  17 - access(ROWID=ROWID)
"  22 - access(""F"".""NAZEV""='Válka Bohů')"
```

### Vysledek

```
Nazev (15 rows)
---------------------------------------------------------------------
Antikrist
Havran
Hollywood v koncích
Jeden musí z kola ven
Lítám v tom
Musíme si promluvit o Kevinovi
Na samotě u lesa
Poznáš muže svých snů
Pretty Woman
Pátý element
Sněhurka
V jako Vendeta 
Válka Bohů
Věčný svit neposkvrněné mysli
Černá labuť
```

Nepatrne zrychleni jeste diky INDEXUM ktere jak vidime se zacinaji  nyni v provadecim planu chytat (posledni radky nyni INDEX FAST FULL SCAN).