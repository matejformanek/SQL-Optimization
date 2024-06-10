-- odeberu pokud existuje funkce na oodebrání tabulek a sekvencí
DROP FUNCTION IF EXISTS remove_all();

-- vytvořím funkci která odebere tabulky a sekvence
CREATE or replace FUNCTION remove_all() RETURNS void AS $$
DECLARE
    rec RECORD;
    cmd text;
BEGIN
    cmd := '';

    FOR rec IN SELECT
            'DROP SEQUENCE ' || quote_ident(n.nspname) || '.'
                || quote_ident(c.relname) || ' CASCADE;' AS name
        FROM
            pg_catalog.pg_class AS c
        LEFT JOIN
            pg_catalog.pg_namespace AS n
        ON
            n.oid = c.relnamespace
        WHERE
            relkind = 'S' AND
            n.nspname NOT IN ('pg_catalog', 'pg_toast') AND
            pg_catalog.pg_table_is_visible(c.oid)
    LOOP
        cmd := cmd || rec.name;
    END LOOP;

    FOR rec IN SELECT
            'DROP TABLE ' || quote_ident(n.nspname) || '.'
                || quote_ident(c.relname) || ' CASCADE;' AS name
        FROM
            pg_catalog.pg_class AS c
        LEFT JOIN
            pg_catalog.pg_namespace AS n
        ON
            n.oid = c.relnamespace WHERE relkind = 'r' AND
            n.nspname NOT IN ('pg_catalog', 'pg_toast') AND
            pg_catalog.pg_table_is_visible(c.oid)
    LOOP
        cmd := cmd || rec.name;
    END LOOP;

    EXECUTE cmd;
    RETURN;
END;
$$ LANGUAGE plpgsql;
-- zavolám funkci co odebere tabulky a sekvence - Mohl bych dropnout celé schéma a znovu jej vytvořit, použíjeme však PLSQL
-- Kod z ukazkove semestralni prace "Zoo ve skluzu"
select remove_all();

CREATE TABLE adresa (
    id_adresa SERIAL NOT NULL,
    mesto VARCHAR(256) NOT NULL,
    ulice VARCHAR(256) NOT NULL,
    cislo_popisne INTEGER
);
ALTER TABLE adresa ADD CONSTRAINT pk_adresa PRIMARY KEY (id_adresa);

CREATE TABLE firma (
    id_firma SERIAL NOT NULL,
    nazev_firmy VARCHAR(256) NOT NULL
);
ALTER TABLE firma ADD CONSTRAINT pk_firma PRIMARY KEY (id_firma);

CREATE TABLE koreni (
    id_koreni SERIAL NOT NULL,
    nazev_koreni VARCHAR(256) NOT NULL,
    mnozstvi INTEGER NOT NULL,
    cena INTEGER,
    datum DATE
);
ALTER TABLE koreni ADD CONSTRAINT pk_koreni PRIMARY KEY (id_koreni);

CREATE TABLE nakup (
    id_nakup SERIAL NOT NULL,
    id_koreni INTEGER,
    mnozstvi INTEGER NOT NULL,
    cena INTEGER NOT NULL,
    datum DATE NOT NULL
);
ALTER TABLE nakup ADD CONSTRAINT pk_nakup PRIMARY KEY (id_nakup);

CREATE TABLE pozice (
    id_pozice SERIAL NOT NULL,
    nazev_pozice VARCHAR(256) NOT NULL
);
ALTER TABLE pozice ADD CONSTRAINT pk_pozice PRIMARY KEY (id_pozice);

CREATE TABLE prodej (
    id_prodej SERIAL NOT NULL,
    id_firma INTEGER NOT NULL,
    id_produkt INTEGER NOT NULL,
    id_ridic INTEGER NOT NULL,
    mnozstvi INTEGER NOT NULL,
    cena INTEGER NOT NULL,
    datum DATE NOT NULL
);
ALTER TABLE prodej ADD CONSTRAINT pk_prodej PRIMARY KEY (id_prodej);

CREATE TABLE produkt (
    id_produkt SERIAL NOT NULL,
    id_zamestnanec INTEGER NOT NULL,
    nazev_produktu VARCHAR(256) NOT NULL,
    mnozstvi INTEGER NOT NULL
);
ALTER TABLE produkt ADD CONSTRAINT pk_produkt PRIMARY KEY (id_produkt);

CREATE TABLE ridic (
    id_ridic SERIAL NOT NULL,
    id_firma INTEGER NOT NULL,
    id_zamestnanec INTEGER,
    jmeno VARCHAR(256)
);
ALTER TABLE ridic ADD CONSTRAINT pk_ridic PRIMARY KEY (id_ridic);
ALTER TABLE ridic ADD CONSTRAINT u_fk_ridic_zamestnanec UNIQUE (id_zamestnanec);

CREATE TABLE skladnik (
    id_zamestnanec INTEGER NOT NULL,
    jmeno VARCHAR(256) NOT NULL,
    delka_prace INTEGER
);
ALTER TABLE skladnik ADD CONSTRAINT pk_skladnik PRIMARY KEY (id_zamestnanec);

CREATE TABLE zamestnanec (
    id_zamestnanec SERIAL NOT NULL,
    id_adresa INTEGER NOT NULL,
    id_pozice INTEGER NOT NULL,
    osobni_cislo VARCHAR(256) NOT NULL,
    plat INTEGER NOT NULL
);
ALTER TABLE zamestnanec ADD CONSTRAINT pk_zamestnanec PRIMARY KEY (id_zamestnanec);
ALTER TABLE zamestnanec ADD CONSTRAINT uc_zamestnanec_osobni_cislo UNIQUE (osobni_cislo);

CREATE TABLE produkt_koreni (
    id_produkt INTEGER NOT NULL,
    id_koreni INTEGER NOT NULL
);
ALTER TABLE produkt_koreni ADD CONSTRAINT pk_produkt_koreni PRIMARY KEY (id_produkt, id_koreni);

ALTER TABLE nakup ADD CONSTRAINT fk_nakup_koreni FOREIGN KEY (id_koreni) REFERENCES koreni (id_koreni) ON DELETE CASCADE;

ALTER TABLE prodej ADD CONSTRAINT fk_prodej_firma FOREIGN KEY (id_firma) REFERENCES firma (id_firma) ON DELETE CASCADE;
ALTER TABLE prodej ADD CONSTRAINT fk_prodej_produkt FOREIGN KEY (id_produkt) REFERENCES produkt (id_produkt) ON DELETE CASCADE;
ALTER TABLE prodej ADD CONSTRAINT fk_prodej_ridic FOREIGN KEY (id_ridic) REFERENCES ridic (id_ridic) ON DELETE CASCADE;

ALTER TABLE produkt ADD CONSTRAINT fk_produkt_skladnik FOREIGN KEY (id_zamestnanec) REFERENCES skladnik (id_zamestnanec) ON DELETE CASCADE;

ALTER TABLE ridic ADD CONSTRAINT fk_ridic_firma FOREIGN KEY (id_firma) REFERENCES firma (id_firma) ON DELETE CASCADE;
ALTER TABLE ridic ADD CONSTRAINT fk_ridic_zamestnanec FOREIGN KEY (id_zamestnanec) REFERENCES zamestnanec (id_zamestnanec) ON DELETE CASCADE;

ALTER TABLE skladnik ADD CONSTRAINT fk_skladnik_zamestnanec FOREIGN KEY (id_zamestnanec) REFERENCES zamestnanec (id_zamestnanec) ON DELETE CASCADE;

ALTER TABLE zamestnanec ADD CONSTRAINT fk_zamestnanec_adresa FOREIGN KEY (id_adresa) REFERENCES adresa (id_adresa) ON DELETE CASCADE;
ALTER TABLE zamestnanec ADD CONSTRAINT fk_zamestnanec_pozice FOREIGN KEY (id_pozice) REFERENCES pozice (id_pozice) ON DELETE CASCADE;

ALTER TABLE produkt_koreni ADD CONSTRAINT fk_produkt_koreni_produkt FOREIGN KEY (id_produkt) REFERENCES produkt (id_produkt) ON DELETE CASCADE;
ALTER TABLE produkt_koreni ADD CONSTRAINT fk_produkt_koreni_koreni FOREIGN KEY (id_koreni) REFERENCES koreni (id_koreni) ON DELETE CASCADE;

commit;