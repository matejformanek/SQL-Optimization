-- smazání všech záznamů z tabulek

CREATE or replace FUNCTION clean_tables() RETURNS void AS $$
declare
  l_stmt text;
begin
  select 'truncate ' || string_agg(format('%I.%I', schemaname, tablename) , ',')
    into l_stmt
  from pg_tables
  where schemaname in ('public');

  execute l_stmt || ' cascade';
end;
$$ LANGUAGE plpgsql;
select clean_tables();

-- reset sekvenci

CREATE or replace FUNCTION restart_sequences() RETURNS void AS $$
DECLARE
i TEXT;
BEGIN
 FOR i IN (SELECT column_default FROM information_schema.columns WHERE column_default SIMILAR TO 'nextval%')
  LOOP
         EXECUTE 'ALTER SEQUENCE'||' ' || substring(substring(i from '''[a-z_]*')from '[a-z_]+') || ' '||' RESTART 1;';
  END LOOP;
END $$ LANGUAGE plpgsql;
select restart_sequences();
-- konec resetu

-- konec mazání
-- mohli bchom použít i jednotlivé příkazy truncate na každo tabulku

--smaza vrsek copy ze Zoo ve skluzu

insert into pozice (id_pozice, nazev_pozice) values (1, 'Skladnik');
insert into pozice (id_pozice, nazev_pozice) values (2, 'Ridic');
insert into pozice (id_pozice, nazev_pozice) values (3, 'Sekretarka');
insert into pozice (id_pozice, nazev_pozice) values (4, 'Uklizecka');
insert into pozice (id_pozice, nazev_pozice) values (5, 'Sef');

select setval(pg_get_serial_sequence('pozice','id_pozice'),5);
-- viz proseminar

insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (1, 'Ricany', 'Lien', '6825');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (2, 'Ricany', 'Sunnyside', '5919');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (3, 'Ricany', 'Stuart', '2089');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (4, 'Ricany', 'Myrtle', '228');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (5, 'Svetice', 'Mendota', '3277');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (6, 'Svetice', 'Londonderry', '87');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (7, 'Svetice', 'Redwing', '6845');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (8, 'Svetice', 'Clarendon', '1');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (9, 'Svetice', 'Prentice', '86');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (10, 'Tehov', 'Arizona', '505');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (11, 'Tehov', 'Stephen', '1');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (12, 'Tehov', 'Jana', '78');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (13, 'Tehov', 'Heath', '39610');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (14, 'Kunice', 'Cody', '99');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (15, 'Kunice', 'Manufacturers', '43');
insert into adresa (id_adresa, mesto, ulice, cislo_popisne) values (16, 'Kunice', 'Holmberg', '32');

select setval(pg_get_serial_sequence('adresa','id_adresa'),16);

insert into firma (id_firma, nazev_firmy) values (0, 'Kasia');
insert into firma (id_firma, nazev_firmy) values (1, 'Yamia');
insert into firma (id_firma, nazev_firmy) values (2, 'Yozio');
insert into firma (id_firma, nazev_firmy) values (3, 'Fivespan');
insert into firma (id_firma, nazev_firmy) values (4, 'Eidel');
insert into firma (id_firma, nazev_firmy) values (5, 'Tambee');
insert into firma (id_firma, nazev_firmy) values (6, 'Tagchat');
insert into firma (id_firma, nazev_firmy) values (7, 'Zoozzy');
insert into firma (id_firma, nazev_firmy) values (8, 'Rhybox');
insert into firma (id_firma, nazev_firmy) values (9, 'Youspan');

select setval(pg_get_serial_sequence('firma','id_firma'),10);

insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (1, 'Cannabis', 3077, null, '2022-01-09');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (2, 'Xanax', 405, null, '2022-02-07');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (3, 'Zlate kure', 2507, null, '2022-05-26');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (4, 'Crystal', 522, null, '2022-06-05');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (5, 'Pervitin', 203, null, '2019-12-21');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (6, 'Cannabi Thai', 8298, 6902, null);
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (7, 'Metanfetamin light', 970, null, '2022-10-30');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (8, 'Flumazenil', 87, null, null);
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (9, 'Metanfetamin', 3504, null, '2022-10-23');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (10, 'Cannabi durban', 273, null, null);
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (11, 'Cannabi oaxacan', 833, null, '2022-12-08');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (12, 'Paroxetine', 54, 2394, '2020-11-20');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (13, 'Vegeta', 3268, null, '2023-02-07');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (14, 'Cannabi purple kush', 2079, null, '2022-12-15');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (15, 'Cannabi nepalese', 52, null, null);
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (16, 'Cannabi columbian', 7916, null, null);
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (17, 'ATACAND', 210, 2732, '2021-01-11');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (18, 'Diphenhydramine HCL', 5837, null, '2021-07-07');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (19, 'Aurum Metallicum', 199, 8349, null);
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (20, 'Grilovaci', 297, null, null);
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (21, 'Oxybutynin Chloride', 4845, null, null);
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (22, 'Lotrimin AF', 6602, null, '2019-12-24');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (23, 'Fluoxetine', 19, null, '2019-12-13');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (24, 'Jehneci', 666, null, '2021-08-08');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (25, 'H-Insomnia Formula', 2840, null, '2020-04-14');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (26, 'Midazolam', 62, null, '2020-02-23');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (27, 'Naproxen', 12, null, null);
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (28, 'Haloperidol Decanoate', 681, 7491, null);
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (29, 'Helium', 4049, null, '2020-09-14');
insert into koreni (id_koreni, nazev_koreni, mnozstvi, cena, datum) values (30, 'Stool Softener', 858, null, null);

select setval(pg_get_serial_sequence('koreni','id_koreni'),30);

insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (1, 19, 2231020, 7006, '2022-05-12');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (2, 7, 3481049, 5257, '2021-06-20');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (3, 23, 2010562, 4956, '2021-01-27');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (4, 18, 5520320, 3547, '2022-02-05');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (5, 11, 3607636, 2852, '2022-04-15');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (6, 9, 6943138, 7601, '2021-10-24');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (7, 4, 5961184, 5120, '2022-02-17');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (8, 30, 8132681, 7349, '2021-07-31');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (9, 5, 8542359, 4854, '2020-08-31');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (10, 23, 927094, 9535, '2022-02-07');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (11, 5, 2356764, 1356, '2023-02-28');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (12, 5, 7902424, 4439, '2020-08-31');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (13, 27, 9055490, 6267, '2022-09-23');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (14, 24, 2690193, 889, '2020-04-18');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (15, 10, 9805924, 3917, '2020-01-28');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (16, 4, 5991974, 8347, '2022-05-08');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (17, 18, 7712757, 3887, '2020-12-22');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (18, 27, 6442038, 1519, '2020-03-28');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (19, 5, 7194976, 8433, '2022-11-02');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (20, 10, 3535291, 6622, '2020-02-23');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (21, 17, 1348141, 9698, '2022-01-10');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (22, 5, 9348363, 3595, '2022-08-31');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (23, 4, 5541498, 191, '2022-03-28');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (24, 29, 9258742, 8557, '2021-03-23');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (25, 26, 9568873, 3340, '2020-03-11');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (26, 8, 9720067, 8302, '2021-04-28');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (27, 25, 4734324, 9281, '2020-06-05');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (28, 2, 4873543, 2026, '2021-05-20');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (29, 1, 5660733, 5984, '2020-08-20');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (30, 25, 2119194, 3533, '2021-06-05');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (31, 11, 3686286, 4704, '2022-04-02');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (32, 4, 3421504, 9818, '2020-10-19');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (33, 13, 7682770, 4567, '2020-08-24');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (34, 14, 6348728, 8725, '2020-10-24');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (35, 24, 8289910, 5791, '2021-03-27');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (36, 23, 1109696, 4423, '2022-05-19');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (37, 1, 1906937, 7815, '2021-06-18');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (38, 23, 877553, 3696, '2022-02-26');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (39, 2, 4452170, 8268, '2020-01-27');
insert into nakup (id_nakup, id_koreni, mnozstvi, cena, datum) values (40, 30, 1246608, 528, '2020-06-04');

select setval(pg_get_serial_sequence('nakup','id_nakup'),40);

insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (1, 1, 9, 3160225, 6408);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (2, 1, 3, 8238710, 9077);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (3, 1, 1, 5426643, 32842);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (4, 1, 14, 8173259, 222);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (5, 1, 10, 1363295, 27419);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (6, 1, 9, 9718734, 14615);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (7, 1, 6, 7783569, 2883);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (8, 2, 4, 7977126, 25818);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (9, 2, 1, 6675076, 17227);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (10, 2, 1, 7017152, 10607);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (11, 2, 11, 8764753, 11591);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (12, 3, 2, 7008539, 6169);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (13, 4, 10, 6443103, 13901);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (14, 3, 2, 6597984, 4569);
insert into zamestnanec (id_zamestnanec, id_pozice, id_adresa, osobni_cislo, plat) values (15, 5, 7, 5633853, 25505);

select setval(pg_get_serial_sequence('zamestnanec','id_zamestnanec'),15);

insert into skladnik (id_zamestnanec, jmeno, delka_prace) values (1, 'Matej', 132);
insert into skladnik (id_zamestnanec, jmeno, delka_prace) values (2, 'Beata', null);
insert into skladnik (id_zamestnanec, jmeno, delka_prace) values (3, 'Viktorie', 160);
insert into skladnik (id_zamestnanec, jmeno, delka_prace) values (4, 'Martina', 344);
insert into skladnik (id_zamestnanec, jmeno, delka_prace) values (5, 'Jaraoslav', null);
insert into skladnik (id_zamestnanec, jmeno, delka_prace) values (6, 'Petr', 82);
insert into skladnik (id_zamestnanec, jmeno, delka_prace) values (7, 'Krystof', null);

select setval(pg_get_serial_sequence('skladnik','id_zamestnanec'),7);

insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (1, 2, 'LSD', 1703);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (2, 2, 'Extaze', 436);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (3, 2, 'Koule', 1819);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (4, 2, 'Speed', 43);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (5, 2, 'Krystal', 837);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (6, 3, 'Diazepam', 1747);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (7, 5, 'Efko', 130);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (8, 2, 'Andelsky prach', 1648);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (9, 3, 'Hasis', 765);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (10, 7, 'Heroin', 557);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (11, 7, 'Speedball', 1103);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (12, 6, 'Kokain', 346);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (13, 6, 'Crack', 285);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (14, 6, 'Koka', 1379);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (15, 6, 'Snih', 626);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (16, 3, 'Papirek', 300);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (17, 5, 'Lysohlavky', 1329);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (18, 7, 'Houbicky', 1499);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (19, 4, 'Marihuana', 415);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (20, 6, 'Brko', 832);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (21, 6, 'Skero', 1233);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (22, 6, 'Trava', 186);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (23, 2, 'Konopi', 153);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (24, 3, 'Mefedron', 149);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (25, 2, 'Metamfetamin', 267);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (26, 4, 'Pervitin', 852);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (27, 7, 'Pernik', 1802);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (28, 2, 'Parno', 1485);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (29, 7, 'Piko', 1653);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (30, 2, 'Morfin', 1014);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (31, 2, 'Duhovka', 1753);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (32, 6, 'Toluen', 1116);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (33, 7, 'Esko', 267);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (34, 7, 'Tecko', 1801);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (35, 6, 'Emko', 164);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (36, 7, 'Stesti v prasku', 1834);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (37, 4, 'Pudr', 110);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (38, 4, 'Hacko', 1334);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (39, 4, 'White Lady', 1394);
insert into produkt (id_produkt, id_zamestnanec, nazev_produktu, mnozstvi) values (40, 4, 'Fenmetrazin', 387);

select setval(pg_get_serial_sequence('produkt','id_produkt'),40);

insert into ridic (id_ridic,id_firma,id_zamestnanec,jmeno) values (1,0,8,'Pepa');
insert into ridic (id_ridic,id_firma,id_zamestnanec,jmeno) values (2,0,9,'Franat');
insert into ridic (id_ridic,id_firma,id_zamestnanec,jmeno) values (3,0,10,'Jan');
insert into ridic (id_ridic,id_firma,id_zamestnanec,jmeno) values (4,0,11,'Tonda');
insert into ridic (id_ridic,id_firma,id_zamestnanec,jmeno) values (5,1,null,'Viktor');
insert into ridic (id_ridic,id_firma,id_zamestnanec,jmeno) values (6,1,null,'Vaclav');
insert into ridic (id_ridic,id_firma,id_zamestnanec,jmeno) values (7,1,null,null);
insert into ridic (id_ridic,id_firma,id_zamestnanec,jmeno) values (8,2,null,'Robert');
insert into ridic (id_ridic,id_firma,id_zamestnanec,jmeno) values (9,3,null,'Francek');

select setval(pg_get_serial_sequence('ridic','id_ridic'),9);

insert into produkt_koreni (id_produkt, id_koreni) values (28, 19);
insert into produkt_koreni (id_produkt, id_koreni) values (10, 10);
insert into produkt_koreni (id_produkt, id_koreni) values (13, 5);
insert into produkt_koreni (id_produkt, id_koreni) values (5, 15);
insert into produkt_koreni (id_produkt, id_koreni) values (19, 12);
insert into produkt_koreni (id_produkt, id_koreni) values (32, 24);
insert into produkt_koreni (id_produkt, id_koreni) values (18, 13);
insert into produkt_koreni (id_produkt, id_koreni) values (29, 12);
insert into produkt_koreni (id_produkt, id_koreni) values (39, 8);
insert into produkt_koreni (id_produkt, id_koreni) values (24, 30);
insert into produkt_koreni (id_produkt, id_koreni) values (23, 22);
insert into produkt_koreni (id_produkt, id_koreni) values (31, 4);
insert into produkt_koreni (id_produkt, id_koreni) values (30, 11);
insert into produkt_koreni (id_produkt, id_koreni) values (3, 8);
insert into produkt_koreni (id_produkt, id_koreni) values (31, 10);
insert into produkt_koreni (id_produkt, id_koreni) values (35, 7);
insert into produkt_koreni (id_produkt, id_koreni) values (7, 8);
insert into produkt_koreni (id_produkt, id_koreni) values (23, 21);
insert into produkt_koreni (id_produkt, id_koreni) values (15, 29);
insert into produkt_koreni (id_produkt, id_koreni) values (10, 22);
insert into produkt_koreni (id_produkt, id_koreni) values (5, 3);
insert into produkt_koreni (id_produkt, id_koreni) values (14, 29);
insert into produkt_koreni (id_produkt, id_koreni) values (28, 18);
insert into produkt_koreni (id_produkt, id_koreni) values (29, 25);
insert into produkt_koreni (id_produkt, id_koreni) values (35, 2);
insert into produkt_koreni (id_produkt, id_koreni) values (12, 19);
insert into produkt_koreni (id_produkt, id_koreni) values (11, 22);
insert into produkt_koreni (id_produkt, id_koreni) values (40, 19);
insert into produkt_koreni (id_produkt, id_koreni) values (29, 2);
insert into produkt_koreni (id_produkt, id_koreni) values (34, 15);
insert into produkt_koreni (id_produkt, id_koreni) values (36, 18);
insert into produkt_koreni (id_produkt, id_koreni) values (5, 21);
insert into produkt_koreni (id_produkt, id_koreni) values (37, 30);
insert into produkt_koreni (id_produkt, id_koreni) values (2, 3);
insert into produkt_koreni (id_produkt, id_koreni) values (38, 8);
insert into produkt_koreni (id_produkt, id_koreni) values (28, 6);
insert into produkt_koreni (id_produkt, id_koreni) values (1, 17);
insert into produkt_koreni (id_produkt, id_koreni) values (5, 29);
insert into produkt_koreni (id_produkt, id_koreni) values (9, 21);
insert into produkt_koreni (id_produkt, id_koreni) values (15, 11);

insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (1, 2, 5, 8, 2940, 44219, '2021-08-18');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (2, 2, 7, 8, 1367, 23188, '2022-01-08');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (3, 3, 36, 9, 1863, 71911, '2022-10-12');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (4, 9, 39, 3, 3060, 38834, '2022-03-24');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (5, 8, 13, 3, 2359, 39634, '2021-05-28');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (6, 9, 7, 2, 4418, 29427, '2021-10-12');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (7, 3, 31, 9, 117, 23242, '2023-04-08');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (8, 3, 22, 1, 3835, 10492, '2022-03-14');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (9, 8, 30, 2, 1995, 4091, '2022-06-06');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (10, 3, 16, 9, 3285, 34876, '2022-12-30');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (11, 7, 27, 4, 4495, 40424, '2021-08-08');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (12, 1, 7, 7, 1226, 17977, '2022-12-24');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (13, 2, 28, 2, 1366, 35244, '2022-03-19');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (14, 6, 30, 3, 4377, 38532, '2022-10-23');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (15, 1, 21, 5, 2511, 5613, '2022-10-22');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (16, 6, 16, 3, 79, 41690, '2023-03-22');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (17, 1, 28, 6, 4482, 72185, '2021-10-04');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (18, 4, 12, 1, 3242, 78760, '2021-09-05');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (19, 4, 15, 2, 3825, 50909, '2021-08-03');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (20, 2, 34, 8, 231, 72986, '2022-11-02');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (21, 1, 1, 5, 1397, 54351, '2021-07-27');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (22, 2, 1, 8, 2952, 4929, '2021-06-05');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (23, 3, 1, 9, 1213, 81097, '2023-04-09');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (24, 4, 1, 4, 1509, 40234, '2022-04-02');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (25, 5, 1, 1, 1381, 61657, '2022-06-15');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (26, 6, 1, 2, 902, 85189, '2021-12-08');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (27, 7, 1, 4, 854, 59317, '2021-04-14');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (28, 8, 1, 2, 1199, 36581, '2022-04-07');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (29, 9, 1, 3, 4821, 79476, '2022-04-10');
insert into prodej (id_prodej, id_firma, id_produkt, id_ridic, mnozstvi, cena, datum) values (30, 1, 1, 6, 2579, 74929, '2021-08-12');


select setval(pg_get_serial_sequence('prodej','id_prodej'),30);

commit;