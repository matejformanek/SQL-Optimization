# For each drug find best(max) selling teritory(city, district)  up to date(sum) (PostgreSQL)

We need to get the SUM of all sells in each teritory and than find the MAX selling territory for each drug.

## Diagram

![alt text](diagram.png)

## Queries

### 1) Naive

```sql
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
```

### Plan

```
Sort  (cost=7913.90..7913.90 rows=2 width=67) (actual time=29.902..29.907 rows=10 loops=1)
  Sort Key: c.am_sold DESC
  Sort Method: quicksort  Memory: 25kB
  ->  Subquery Scan on c  (cost=20.34..7913.89 rows=2 width=67) (actual time=2.331..29.876 rows=10 loops=1)
        Filter: (c.am_sold = (SubPlan 1))
        Rows Removed by Filter: 322
        ->  HashAggregate  (cost=20.34..26.28 rows=475 width=67) (actual time=0.934..1.036 rows=332 loops=1)
"              Group Key: teritorium.city, teritorium.district, drug.name"
              Batches: 1  Memory Usage: 105kB
              ->  Hash Join  (cost=3.73..15.59 rows=475 width=43) (actual time=0.434..0.694 rows=475 loops=1)
                    Hash Cond: (sold.teritorium_id = teritorium.teritorium_id)
                    ->  Hash Join  (cost=1.23..11.76 rows=475 width=24) (actual time=0.302..0.472 rows=475 loops=1)
                          Hash Cond: (sold.drug_id = drug.drug_id)
                          ->  Seq Scan on sold  (cost=0.00..8.75 rows=475 width=16) (actual time=0.276..0.337 rows=475 loops=1)
                          ->  Hash  (cost=1.10..1.10 rows=10 width=16) (actual time=0.013..0.014 rows=10 loops=1)
                                Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                ->  Seq Scan on drug  (cost=0.00..1.10 rows=10 width=16) (actual time=0.004..0.006 rows=10 loops=1)
                    ->  Hash  (cost=1.67..1.67 rows=67 width=27) (actual time=0.118..0.119 rows=67 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 12kB
                          ->  Seq Scan on teritorium  (cost=0.00..1.67 rows=67 width=27) (actual time=0.094..0.102 rows=67 loops=1)
        SubPlan 1
          ->  GroupAggregate  (cost=14.79..16.59 rows=48 width=44) (actual time=0.086..0.086 rows=1 loops=332)
                Group Key: drug_1.name
                ->  HashAggregate  (cost=14.79..15.39 rows=48 width=67) (actual time=0.078..0.083 rows=34 loops=332)
"                      Group Key: teritorium_1.city, teritorium_1.district, drug_1.name"
                      Batches: 1  Memory Usage: 24kB
                      ->  Hash Join  (cost=3.65..14.31 rows=48 width=43) (actual time=0.005..0.063 rows=48 loops=332)
                            Hash Cond: (sold_1.teritorium_id = teritorium_1.teritorium_id)
                            ->  Hash Join  (cost=1.14..11.67 rows=48 width=24) (actual time=0.004..0.057 rows=48 loops=332)
                                  Hash Cond: (sold_1.drug_id = drug_1.drug_id)
                                  ->  Seq Scan on sold sold_1  (cost=0.00..8.75 rows=475 width=16) (actual time=0.001..0.023 rows=475 loops=332)
                                  ->  Hash  (cost=1.12..1.12 rows=1 width=16) (actual time=0.001..0.001 rows=1 loops=332)
                                        Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                        ->  Seq Scan on drug drug_1  (cost=0.00..1.12 rows=1 width=16) (actual time=0.001..0.001 rows=1 loops=332)
                                              Filter: ((c.name)::text = (name)::text)
                                              Rows Removed by Filter: 9
                            ->  Hash  (cost=1.67..1.67 rows=67 width=27) (actual time=0.025..0.025 rows=67 loops=1)
                                  Buckets: 1024  Batches: 1  Memory Usage: 12kB
                                  ->  Seq Scan on teritorium teritorium_1  (cost=0.00..1.67 rows=67 width=27) (actual time=0.002..0.010 rows=67 loops=1)
Planning Time: 24.277 ms
Execution Time: 30.111 ms
```

### Result

| city             | district            | name                 | amount sold |
|------------------|---------------------|----------------------|-------------|
| Tijuana          | Playas de Tijuana   | Cocaine              | 774         |
| Guadalajara      | Americana           | Ketamine             | 743         |
| Culiacán         | Infonavit Barrancos | Heroin               | 679         |
| Cancún           | Playa Tortugas      | Marijuana            | 661         |
| Culiacán         | Las Quintas         | Psilocybin Mushrooms | 648         |
| Guadalajara      | Zona Centro         | Crack Cocaine        | 635         |
| Tijuana          | San Antonio del Mar | MDMA (Ecstasy)       | 528         |
| Cabo San Lucas   | El Médano           | Methamphetamine      | 510         |
| Tepito           | Buenavista          | LSD                  | 443         |
| Oaxaca de Juárez | Volcanes            | PCP (Angel Dust)     | 442         |

We are calling 2 times the same query -> we can use WITH (CTE) to make it faster.

### 2) CTE

```sql
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
```

### Plan

```
Sort  (cost=5127.79..5127.79 rows=2 width=1580) (actual time=8.868..8.874 rows=10 loops=1)
  Sort Key: c.am_sold DESC
  Sort Method: quicksort  Memory: 25kB
  CTE cte
    ->  HashAggregate  (cost=20.34..26.28 rows=475 width=67) (actual time=0.371..0.427 rows=332 loops=1)
"          Group Key: teritorium.city, teritorium.district, drug.name"
          Batches: 1  Memory Usage: 105kB
          ->  Hash Join  (cost=3.73..15.59 rows=475 width=43) (actual time=0.082..0.227 rows=475 loops=1)
                Hash Cond: (sold.teritorium_id = teritorium.teritorium_id)
                ->  Hash Join  (cost=1.23..11.76 rows=475 width=24) (actual time=0.027..0.118 rows=475 loops=1)
                      Hash Cond: (sold.drug_id = drug.drug_id)
                      ->  Seq Scan on sold  (cost=0.00..8.75 rows=475 width=16) (actual time=0.007..0.032 rows=475 loops=1)
                      ->  Hash  (cost=1.10..1.10 rows=10 width=16) (actual time=0.015..0.016 rows=10 loops=1)
                            Buckets: 1024  Batches: 1  Memory Usage: 9kB
                            ->  Seq Scan on drug  (cost=0.00..1.10 rows=10 width=16) (actual time=0.009..0.011 rows=10 loops=1)
                ->  Hash  (cost=1.67..1.67 rows=67 width=27) (actual time=0.025..0.026 rows=67 loops=1)
                      Buckets: 1024  Batches: 1  Memory Usage: 12kB
                      ->  Seq Scan on teritorium  (cost=0.00..1.67 rows=67 width=27) (actual time=0.005..0.014 rows=67 loops=1)
  ->  CTE Scan on cte c  (cost=0.00..5101.50 rows=2 width=1580) (actual time=0.714..8.848 rows=10 loops=1)
        Filter: (am_sold = (SubPlan 2))
        Rows Removed by Filter: 322
        SubPlan 2
          ->  GroupAggregate  (cost=0.00..10.72 rows=2 width=548) (actual time=0.025..0.025 rows=1 loops=332)
                Group Key: cte.name
                ->  CTE Scan on cte  (cost=0.00..10.69 rows=2 width=548) (actual time=0.001..0.021 rows=34 loops=332)
                      Filter: ((c.name)::text = (name)::text)
                      Rows Removed by Filter: 298
Planning Time: 0.297 ms
Execution Time: 8.943 ms
```

### Result

Way better planning and cost but still checking the max in WHERE is very slow -> HAVING

### 3) HAVING

```sql
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
```

### Plan

```
Sort  (cost=2187.72..2187.73 rows=1 width=1580) (actual time=8.554..8.559 rows=10 loops=1)
  Sort Key: c.am_sold DESC
  Sort Method: quicksort  Memory: 25kB
  CTE cte
    ->  HashAggregate  (cost=20.34..26.28 rows=475 width=67) (actual time=0.313..0.395 rows=332 loops=1)
"          Group Key: teritorium.city, teritorium.district, drug.name"
          Batches: 1  Memory Usage: 105kB
          ->  Hash Join  (cost=3.73..15.59 rows=475 width=43) (actual time=0.036..0.177 rows=475 loops=1)
                Hash Cond: (sold.teritorium_id = teritorium.teritorium_id)
                ->  Hash Join  (cost=1.23..11.76 rows=475 width=24) (actual time=0.019..0.107 rows=475 loops=1)
                      Hash Cond: (sold.drug_id = drug.drug_id)
                      ->  Seq Scan on sold  (cost=0.00..8.75 rows=475 width=16) (actual time=0.005..0.029 rows=475 loops=1)
                      ->  Hash  (cost=1.10..1.10 rows=10 width=16) (actual time=0.008..0.009 rows=10 loops=1)
                            Buckets: 1024  Batches: 1  Memory Usage: 9kB
                            ->  Seq Scan on drug  (cost=0.00..1.10 rows=10 width=16) (actual time=0.003..0.004 rows=10 loops=1)
                ->  Hash  (cost=1.67..1.67 rows=67 width=27) (actual time=0.014..0.015 rows=67 loops=1)
                      Buckets: 1024  Batches: 1  Memory Usage: 12kB
                      ->  Seq Scan on teritorium  (cost=0.00..1.67 rows=67 width=27) (actual time=0.003..0.007 rows=67 loops=1)
  ->  HashAggregate  (cost=15.44..2161.44 rows=1 width=1580) (actual time=1.797..8.543 rows=10 loops=1)
"        Group Key: c.am_sold, c.city, c.district, c.name"
        Filter: (max(c.am_sold) = (SubPlan 2))
        Batches: 1  Memory Usage: 109kB
        Rows Removed by Filter: 322
        ->  CTE Scan on cte c  (cost=0.00..9.50 rows=475 width=1580) (actual time=0.314..0.507 rows=332 loops=1)
        SubPlan 2
          ->  GroupAggregate  (cost=0.00..10.72 rows=2 width=548) (actual time=0.023..0.023 rows=1 loops=332)
                Group Key: cte.name
                ->  CTE Scan on cte  (cost=0.00..10.69 rows=2 width=548) (actual time=0.001..0.020 rows=34 loops=332)
                      Filter: ((name)::text = (c.name)::text)
                      Rows Removed by Filter: 298
Planning Time: 0.242 ms
Execution Time: 8.625 ms
```

### Result

Half the cost but not really moving the time. We can use JOIN (very powerful) to match it and finally get pretty
optimized query.

### 4) OPTIMIZED

```sql
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
```

### Plan

```
Sort  (cost=57.15..57.16 rows=2 width=1580) (actual time=0.629..0.631 rows=10 loops=1)
  Sort Key: c.am_sold DESC
  Sort Method: quicksort  Memory: 25kB
  CTE cte
    ->  HashAggregate  (cost=20.34..26.28 rows=475 width=67) (actual time=0.320..0.377 rows=332 loops=1)
"          Group Key: teritorium.city, teritorium.district, drug.name"
          Batches: 1  Memory Usage: 105kB
          ->  Hash Join  (cost=3.73..15.59 rows=475 width=43) (actual time=0.037..0.181 rows=475 loops=1)
                Hash Cond: (sold.teritorium_id = teritorium.teritorium_id)
                ->  Hash Join  (cost=1.23..11.76 rows=475 width=24) (actual time=0.019..0.109 rows=475 loops=1)
                      Hash Cond: (sold.drug_id = drug.drug_id)
                      ->  Seq Scan on sold  (cost=0.00..8.75 rows=475 width=16) (actual time=0.005..0.030 rows=475 loops=1)
                      ->  Hash  (cost=1.10..1.10 rows=10 width=16) (actual time=0.009..0.009 rows=10 loops=1)
                            Buckets: 1024  Batches: 1  Memory Usage: 9kB
                            ->  Seq Scan on drug  (cost=0.00..1.10 rows=10 width=16) (actual time=0.003..0.004 rows=10 loops=1)
                ->  Hash  (cost=1.67..1.67 rows=67 width=27) (actual time=0.014..0.014 rows=67 loops=1)
                      Buckets: 1024  Batches: 1  Memory Usage: 12kB
                      ->  Seq Scan on teritorium  (cost=0.00..1.67 rows=67 width=27) (actual time=0.002..0.006 rows=67 loops=1)
  ->  Hash Join  (cost=18.88..30.87 rows=2 width=1580) (actual time=0.554..0.621 rows=10 loops=1)
        Hash Cond: ((c.am_sold = ag.am) AND ((c.name)::text = (ag.name)::text))
        ->  CTE Scan on cte c  (cost=0.00..9.50 rows=475 width=1580) (actual time=0.322..0.340 rows=332 loops=1)
        ->  Hash  (cost=15.88..15.88 rows=200 width=548) (actual time=0.227..0.227 rows=10 loops=1)
              Buckets: 1024  Batches: 1  Memory Usage: 9kB
              ->  Subquery Scan on ag  (cost=11.88..15.88 rows=200 width=548) (actual time=0.222..0.225 rows=10 loops=1)
                    ->  HashAggregate  (cost=11.88..13.88 rows=200 width=548) (actual time=0.222..0.224 rows=10 loops=1)
                          Group Key: cte.name
                          Batches: 1  Memory Usage: 40kB
                          ->  CTE Scan on cte  (cost=0.00..9.50 rows=475 width=548) (actual time=0.000..0.153 rows=332 loops=1)
Planning Time: 0.308 ms
Execution Time: 0.696 ms
```

### Result

Finally acceptable time thanks to the effective JOIN and CTE, very easy to read.

Plus allows easily adding another complicated options. For example SUM of all MAXES and etc... Try adding it to the
previous, besides it being complicated it's also very costly.

```sql
WITH cte AS (SELECT city, district, name, SUM(amount_sold) AS am_sold
             FROM drug
                      JOIN public.sold ON drug.drug_id = sold.drug_id
                      JOIN public.teritorium ON teritorium.teritorium_id = sold.teritorium_id
             GROUP BY city, district, name)
SELECT city, district, c.name, COALESCE(c.am_sold, SUM(am_sold) OVER ())
FROM cte c
         RIGHT JOIN (SELECT name, MAX(am_sold) AS am
                     FROM cte
                     GROUP BY ROLLUP (name)) -- Could be written as UNION SELECT NULL, NULL
    AS ag ON ag.am = c.am_sold AND ag.name = c.name
ORDER BY am_sold DESC;
```

### 5) More stats

Lets try and up it a little to now get the best district, city and sum of all.

```sql
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
```

### Plan

```
Unique  (cost=167.81..167.90 rows=9 width=1580) (actual time=1.343..1.351 rows=30 loops=1)
  CTE cte
    ->  HashAggregate  (cost=20.34..33.59 rows=585 width=67) (actual time=0.465..0.534 rows=439 loops=1)
"          Hash Key: drug.name, teritorium.city, teritorium.district"
"          Hash Key: drug.name, teritorium.city"
          Hash Key: drug.name
          Batches: 1  Memory Usage: 209kB
          ->  Hash Join  (cost=3.73..15.59 rows=475 width=43) (actual time=0.035..0.182 rows=475 loops=1)
                Hash Cond: (sold.teritorium_id = teritorium.teritorium_id)
                ->  Hash Join  (cost=1.23..11.76 rows=475 width=24) (actual time=0.019..0.110 rows=475 loops=1)
                      Hash Cond: (sold.drug_id = drug.drug_id)
                      ->  Seq Scan on sold  (cost=0.00..8.75 rows=475 width=16) (actual time=0.007..0.032 rows=475 loops=1)
                      ->  Hash  (cost=1.10..1.10 rows=10 width=16) (actual time=0.008..0.008 rows=10 loops=1)
                            Buckets: 1024  Batches: 1  Memory Usage: 9kB
                            ->  Seq Scan on drug  (cost=0.00..1.10 rows=10 width=16) (actual time=0.003..0.004 rows=10 loops=1)
                ->  Hash  (cost=1.67..1.67 rows=67 width=27) (actual time=0.014..0.014 rows=67 loops=1)
                      Buckets: 1024  Batches: 1  Memory Usage: 12kB
                      ->  Seq Scan on teritorium  (cost=0.00..1.67 rows=67 width=27) (actual time=0.002..0.006 rows=67 loops=1)
  ->  Sort  (cost=134.22..134.25 rows=9 width=1580) (actual time=1.343..1.344 rows=31 loops=1)
"        Sort Key: c.name, c.am_sold DESC, c.city"
        Sort Method: quicksort  Memory: 27kB
        ->  Merge Join  (cost=125.10..134.08 rows=9 width=1580) (actual time=1.262..1.329 rows=31 loops=1)
"              Merge Cond: (((c.name)::text = (""*SELECT* 1"".name)::text) AND (c.am_sold = ""*SELECT* 1"".am))"
              ->  Sort  (cost=38.59..40.05 rows=585 width=1580) (actual time=0.930..0.944 rows=439 loops=1)
"                    Sort Key: c.name, c.am_sold"
                    Sort Method: quicksort  Memory: 62kB
                    ->  CTE Scan on cte c  (cost=0.00..11.70 rows=585 width=1580) (actual time=0.467..0.658 rows=439 loops=1)
              ->  Sort  (cost=86.52..88.02 rows=600 width=548) (actual time=0.323..0.324 rows=31 loops=1)
"                    Sort Key: ""*SELECT* 1"".name, ""*SELECT* 1"".am"
                    Sort Method: quicksort  Memory: 26kB
                    ->  Append  (cost=14.63..58.83 rows=600 width=548) (actual time=0.107..0.310 rows=30 loops=1)
"                          ->  Subquery Scan on ""*SELECT* 1""  (cost=14.63..18.62 rows=200 width=548) (actual time=0.106..0.109 rows=10 loops=1)"
                                ->  HashAggregate  (cost=14.63..16.62 rows=200 width=548) (actual time=0.106..0.108 rows=10 loops=1)
                                      Group Key: cte.name
                                      Batches: 1  Memory Usage: 40kB
                                      ->  CTE Scan on cte  (cost=0.00..11.70 rows=585 width=548) (actual time=0.000..0.022 rows=439 loops=1)
"                          ->  Subquery Scan on ""*SELECT* 2""  (cost=14.61..18.61 rows=200 width=548) (actual time=0.107..0.109 rows=10 loops=1)"
                                ->  HashAggregate  (cost=14.61..16.61 rows=200 width=548) (actual time=0.107..0.108 rows=10 loops=1)
                                      Group Key: cte_1.name
                                      Batches: 1  Memory Usage: 40kB
                                      ->  CTE Scan on cte cte_1  (cost=0.00..11.70 rows=582 width=548) (actual time=0.000..0.031 rows=429 loops=1)
                                            Filter: (city IS NOT NULL)
                                            Rows Removed by Filter: 10
"                          ->  Subquery Scan on ""*SELECT* 3""  (cost=14.60..18.59 rows=200 width=548) (actual time=0.088..0.090 rows=10 loops=1)"
                                ->  HashAggregate  (cost=14.60..16.59 rows=200 width=548) (actual time=0.087..0.089 rows=10 loops=1)
                                      Group Key: cte_2.name
                                      Batches: 1  Memory Usage: 40kB
                                      ->  CTE Scan on cte cte_2  (cost=0.00..11.70 rows=579 width=548) (actual time=0.000..0.029 rows=332 loops=1)
                                            Filter: ((city IS NOT NULL) AND (district IS NOT NULL))
                                            Rows Removed by Filter: 107
Planning Time: 0.309 ms
Execution Time: 1.428 ms
```

### Result

NULL, NULL = Over all sold of drug

NULL, District = The most sold in a city

City, District = The most sold of drug in district

| city             | district            | name                 | amount sold |
|------------------|---------------------|----------------------|-------------|
|                  |                     | Cocaine              | 7504        |
| Medellín         |                     | Cocaine              | 1704        |
| Tijuana          | Playas de Tijuana   | Cocaine              | 774         |
|                  |                     | Crack Cocaine        | 8113        |
| Guadalajara      |                     | Crack Cocaine        | 1658        |
| Guadalajara      | Zona Centro         | Crack Cocaine        | 635         |
|                  |                     | Heroin               | 7051        |
| Oaxaca de Juárez |                     | Heroin               | 1179        |
| Culiacán         | Infonavit Barrancos | Heroin               | 679         |
|                  |                     | Ketamine             | 7796        |
| Guadalajara      |                     | Ketamine             | 1607        |
| Guadalajara      | Americana           | Ketamine             | 743         |
|                  |                     | LSD                  | 5422        |
| Guadalajara      |                     | LSD                  | 947         |
| Tepito           | Buenavista          | LSD                  | 443         |
|                  |                     | Marijuana            | 8537        |
| Juárez           |                     | Marijuana            | 1531        |
| Cancún           | Playa Tortugas      | Marijuana            | 661         |
|                  |                     | MDMA (Ecstasy)       | 5570        |
| Cabo San Lucas   |                     | MDMA (Ecstasy)       | 802         |
| Tijuana          | San Antonio del Mar | MDMA (Ecstasy)       | 528         |
|                  |                     | Methamphetamine      | 6634        |
| Tijuana          |                     | Methamphetamine      | 1409        |
| Cabo San Lucas   | El Médano           | Methamphetamine      | 510         |
|                  |                     | PCP (Angel Dust)     | 8000        |
| Juárez           |                     | PCP (Angel Dust)     | 1475        |
| Oaxaca de Juárez | Volcanes            | PCP (Angel Dust)     | 442         |
|                  |                     | Psilocybin Mushrooms | 6128        |
| Culiacán         |                     | Psilocybin Mushrooms | 1129        |
| Culiacán         | Las Quintas         | Psilocybin Mushrooms | 648         |

### 6) Plus sum of all

```sql
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
```

### Plan

```
Unique  (cost=203.00..209.01 rows=200 width=1580) (actual time=1.461..1.473 rows=31 loops=1)
  CTE cte
    ->  HashAggregate  (cost=20.34..33.59 rows=585 width=67) (actual time=0.482..0.613 rows=439 loops=1)
"          Hash Key: drug.name, teritorium.city, teritorium.district"
"          Hash Key: drug.name, teritorium.city"
          Hash Key: drug.name
          Batches: 1  Memory Usage: 209kB
          ->  Hash Join  (cost=3.73..15.59 rows=475 width=43) (actual time=0.039..0.190 rows=475 loops=1)
                Hash Cond: (sold.teritorium_id = teritorium.teritorium_id)
                ->  Hash Join  (cost=1.23..11.76 rows=475 width=24) (actual time=0.020..0.117 rows=475 loops=1)
                      Hash Cond: (sold.drug_id = drug.drug_id)
                      ->  Seq Scan on sold  (cost=0.00..8.75 rows=475 width=16) (actual time=0.006..0.036 rows=475 loops=1)
                      ->  Hash  (cost=1.10..1.10 rows=10 width=16) (actual time=0.007..0.007 rows=10 loops=1)
                            Buckets: 1024  Batches: 1  Memory Usage: 9kB
                            ->  Seq Scan on drug  (cost=0.00..1.10 rows=10 width=16) (actual time=0.002..0.003 rows=10 loops=1)
                ->  Hash  (cost=1.67..1.67 rows=67 width=27) (actual time=0.015..0.016 rows=67 loops=1)
                      Buckets: 1024  Batches: 1  Memory Usage: 12kB
                      ->  Seq Scan on teritorium  (cost=0.00..1.67 rows=67 width=27) (actual time=0.003..0.007 rows=67 loops=1)
  ->  Sort  (cost=169.41..170.91 rows=601 width=1580) (actual time=1.460..1.464 rows=32 loops=1)
"        Sort Key: c.name, (CASE WHEN (c.name IS NULL) THEN sum(CASE WHEN ((c.city IS NULL) AND (c.district IS NULL)) THEN c.am_sold ELSE '0'::numeric END) OVER (?) ELSE c.am_sold END) DESC, c.city"
        Sort Method: quicksort  Memory: 27kB
        ->  WindowAgg  (cost=125.17..141.67 rows=601 width=1580) (actual time=1.437..1.444 rows=32 loops=1)
              ->  Merge Left Join  (cost=125.17..134.16 rows=601 width=1580) (actual time=1.394..1.422 rows=32 loops=1)
"                    Merge Cond: ((""*SELECT* 1"".am = c.am_sold) AND ((""*SELECT* 1"".name)::text = (c.name)::text))"
                    ->  Sort  (cost=86.58..88.09 rows=601 width=547) (actual time=1.172..1.175 rows=31 loops=1)
"                          Sort Key: ""*SELECT* 1"".am, ""*SELECT* 1"".name"
                          Sort Method: quicksort  Memory: 26kB
                          ->  Append  (cost=14.63..58.84 rows=601 width=547) (actual time=0.919..1.154 rows=31 loops=1)
"                                ->  Subquery Scan on ""*SELECT* 1""  (cost=14.63..18.62 rows=200 width=548) (actual time=0.918..0.921 rows=10 loops=1)"
                                      ->  HashAggregate  (cost=14.63..16.62 rows=200 width=548) (actual time=0.912..0.914 rows=10 loops=1)
                                            Group Key: cte.name
                                            Batches: 1  Memory Usage: 40kB
                                            ->  CTE Scan on cte  (cost=0.00..11.70 rows=585 width=548) (actual time=0.484..0.776 rows=439 loops=1)
"                                ->  Subquery Scan on ""*SELECT* 2""  (cost=14.61..18.61 rows=200 width=548) (actual time=0.129..0.132 rows=10 loops=1)"
                                      ->  HashAggregate  (cost=14.61..16.61 rows=200 width=548) (actual time=0.128..0.130 rows=10 loops=1)
                                            Group Key: cte_1.name
                                            Batches: 1  Memory Usage: 40kB
                                            ->  CTE Scan on cte cte_1  (cost=0.00..11.70 rows=582 width=548) (actual time=0.002..0.034 rows=429 loops=1)
                                                  Filter: (city IS NOT NULL)
                                                  Rows Removed by Filter: 10
"                                ->  Subquery Scan on ""*SELECT* 3""  (cost=14.60..18.59 rows=200 width=548) (actual time=0.091..0.094 rows=10 loops=1)"
                                      ->  HashAggregate  (cost=14.60..16.59 rows=200 width=548) (actual time=0.090..0.092 rows=10 loops=1)
                                            Group Key: cte_2.name
                                            Batches: 1  Memory Usage: 40kB
                                            ->  CTE Scan on cte cte_2  (cost=0.00..11.70 rows=579 width=548) (actual time=0.001..0.029 rows=332 loops=1)
                                                  Filter: ((city IS NOT NULL) AND (district IS NOT NULL))
                                                  Rows Removed by Filter: 107
                                ->  Result  (cost=0.00..0.01 rows=1 width=64) (actual time=0.001..0.001 rows=1 loops=1)
                    ->  Sort  (cost=38.59..40.05 rows=585 width=1580) (actual time=0.176..0.190 rows=439 loops=1)
"                          Sort Key: c.am_sold, c.name"
                          Sort Method: quicksort  Memory: 62kB
                          ->  CTE Scan on cte c  (cost=0.00..11.70 rows=585 width=1580) (actual time=0.000..0.031 rows=439 loops=1)
Planning Time: 0.855 ms
Execution Time: 1.584 ms
```

### Result

NULL, NULL, NULL = Sum of all

NULL, NULL = Over all sold of drug

NULL, District = The most sold in a city

City, District = The most sold of drug in district

| city             | district            | name                 | amount sold |
|------------------|---------------------|----------------------|-------------|
|                  |                     | Cocaine              | 7504        |
| Medellín         |                     | Cocaine              | 1704        |
| Tijuana          | Playas de Tijuana   | Cocaine              | 774         |
|                  |                     | Crack Cocaine        | 8113        |
| Guadalajara      |                     | Crack Cocaine        | 1658        |
| Guadalajara      | Zona Centro         | Crack Cocaine        | 635         |
|                  |                     | Heroin               | 7051        |
| Oaxaca de Juárez |                     | Heroin               | 1179        |
| Culiacán         | Infonavit Barrancos | Heroin               | 679         |
|                  |                     | Ketamine             | 7796        |
| Guadalajara      |                     | Ketamine             | 1607        |
| Guadalajara      | Americana           | Ketamine             | 743         |
|                  |                     | LSD                  | 5422        |
| Guadalajara      |                     | LSD                  | 947         |
| Tepito           | Buenavista          | LSD                  | 443         |
|                  |                     | Marijuana            | 8537        |
| Juárez           |                     | Marijuana            | 1531        |
| Cancún           | Playa Tortugas      | Marijuana            | 661         |
|                  |                     | MDMA (Ecstasy)       | 5570        |
| Cabo San Lucas   |                     | MDMA (Ecstasy)       | 802         |
| Tijuana          | San Antonio del Mar | MDMA (Ecstasy)       | 528         |
|                  |                     | Methamphetamine      | 6634        |
| Tijuana          |                     | Methamphetamine      | 1409        |
| Cabo San Lucas   | El Médano           | Methamphetamine      | 510         |
|                  |                     | PCP (Angel Dust)     | 8000        |
| Juárez           |                     | PCP (Angel Dust)     | 1475        |
| Oaxaca de Juárez | Volcanes            | PCP (Angel Dust)     | 442         |
|                  |                     | Psilocybin Mushrooms | 6128        |
| Culiacán         |                     | Psilocybin Mushrooms | 1129        |
| Culiacán         | Las Quintas         | Psilocybin Mushrooms | 648         |
|                  |                     |                      | 70755       |

### 7) Multiple joins

bit faster method to get the same result as above

```sql
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
```

### Plan

```
Sort  (cost=149.41..149.43 rows=8 width=1400) (actual time=1.344..1.349 rows=31 loops=1)
"  Sort Key: c.name, (COALESCE(c.am_sold, sum(CASE WHEN ((c.city IS NULL) AND (c.district IS NULL)) THEN c.am_sold ELSE '0'::numeric END) OVER (?))) DESC"
  Sort Method: quicksort  Memory: 27kB
  CTE cte
    ->  HashAggregate  (cost=20.34..33.59 rows=585 width=67) (actual time=0.466..0.537 rows=439 loops=1)
"          Hash Key: drug.name, teritorium.city, teritorium.district"
"          Hash Key: drug.name, teritorium.city"
          Hash Key: drug.name
          Batches: 1  Memory Usage: 209kB
          ->  Hash Join  (cost=3.73..15.59 rows=475 width=43) (actual time=0.044..0.190 rows=475 loops=1)
                Hash Cond: (sold.teritorium_id = teritorium.teritorium_id)
                ->  Hash Join  (cost=1.23..11.76 rows=475 width=24) (actual time=0.024..0.116 rows=475 loops=1)
                      Hash Cond: (sold.drug_id = drug.drug_id)
                      ->  Seq Scan on sold  (cost=0.00..8.75 rows=475 width=16) (actual time=0.007..0.036 rows=475 loops=1)
                      ->  Hash  (cost=1.10..1.10 rows=10 width=16) (actual time=0.008..0.008 rows=10 loops=1)
                            Buckets: 1024  Batches: 1  Memory Usage: 9kB
                            ->  Seq Scan on drug  (cost=0.00..1.10 rows=10 width=16) (actual time=0.003..0.004 rows=10 loops=1)
                ->  Hash  (cost=1.67..1.67 rows=67 width=27) (actual time=0.019..0.019 rows=67 loops=1)
                      Buckets: 1024  Batches: 1  Memory Usage: 12kB
                      ->  Seq Scan on teritorium  (cost=0.00..1.67 rows=67 width=27) (actual time=0.006..0.011 rows=67 loops=1)
  ->  Append  (cost=21.59..115.70 rows=8 width=1398) (actual time=0.829..1.322 rows=31 loops=1)
        ->  WindowAgg  (cost=21.59..36.37 rows=3 width=1580) (actual time=0.828..0.831 rows=10 loops=1)
              ->  Hash Join  (cost=21.59..36.33 rows=3 width=1580) (actual time=0.763..0.816 rows=10 loops=1)
                    Hash Cond: ((c.am_sold = ag.am) AND ((c.name)::text = (ag.name)::text))
                    ->  CTE Scan on cte c  (cost=0.00..11.70 rows=579 width=1580) (actual time=0.469..0.496 rows=332 loops=1)
                          Filter: ((district IS NOT NULL) AND (city IS NOT NULL))
                          Rows Removed by Filter: 107
                    ->  Hash  (cost=18.59..18.59 rows=200 width=548) (actual time=0.276..0.277 rows=10 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 9kB
                          ->  Subquery Scan on ag  (cost=14.60..18.59 rows=200 width=548) (actual time=0.271..0.274 rows=10 loops=1)
                                ->  HashAggregate  (cost=14.60..16.59 rows=200 width=548) (actual time=0.268..0.271 rows=10 loops=1)
                                      Group Key: cte.name
                                      Batches: 1  Memory Usage: 40kB
                                      ->  CTE Scan on cte  (cost=0.00..11.70 rows=579 width=548) (actual time=0.000..0.202 rows=332 loops=1)
                                            Filter: ((district IS NOT NULL) AND (city IS NOT NULL))
                                            Rows Removed by Filter: 107
        ->  Nested Loop  (cost=11.72..23.67 rows=1 width=1580) (actual time=0.105..0.208 rows=10 loops=1)
              Join Filter: ((c_1.am_sold = ag_1.am) AND ((c_1.name)::text = (ag_1.name)::text))
              Rows Removed by Join Filter: 915
              ->  CTE Scan on cte c_1  (cost=0.00..11.70 rows=3 width=1580) (actual time=0.014..0.021 rows=97 loops=1)
                    Filter: ((district IS NULL) AND (city IS NOT NULL))
                    Rows Removed by Filter: 342
              ->  Materialize  (cost=11.72..11.82 rows=3 width=548) (actual time=0.001..0.001 rows=10 loops=97)
                    ->  Subquery Scan on ag_1  (cost=11.72..11.81 rows=3 width=548) (actual time=0.057..0.072 rows=10 loops=1)
                          ->  GroupAggregate  (cost=11.72..11.78 rows=3 width=548) (actual time=0.057..0.071 rows=10 loops=1)
                                Group Key: cte_1.name
                                ->  Sort  (cost=11.72..11.73 rows=3 width=548) (actual time=0.053..0.056 rows=97 loops=1)
                                      Sort Key: cte_1.name
                                      Sort Method: quicksort  Memory: 31kB
                                      ->  CTE Scan on cte cte_1  (cost=0.00..11.70 rows=3 width=548) (actual time=0.014..0.023 rows=97 loops=1)
                                            Filter: ((district IS NULL) AND (city IS NOT NULL))
                                            Rows Removed by Filter: 342
        ->  Hash Join  (cost=21.62..36.40 rows=3 width=1580) (actual time=0.173..0.176 rows=10 loops=1)
              Hash Cond: ((c_2.am_sold = ag_2.am) AND ((c_2.name)::text = (ag_2.name)::text))
              ->  CTE Scan on cte c_2  (cost=0.00..11.70 rows=585 width=1580) (actual time=0.000..0.019 rows=439 loops=1)
              ->  Hash  (cost=18.62..18.62 rows=200 width=548) (actual time=0.104..0.105 rows=10 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 9kB
                    ->  Subquery Scan on ag_2  (cost=14.63..18.62 rows=200 width=548) (actual time=0.100..0.103 rows=10 loops=1)
                          ->  HashAggregate  (cost=14.63..16.62 rows=200 width=548) (actual time=0.100..0.102 rows=10 loops=1)
                                Group Key: cte_2.name
                                Batches: 1  Memory Usage: 40kB
                                ->  CTE Scan on cte cte_2  (cost=0.00..11.70 rows=585 width=548) (actual time=0.000..0.021 rows=439 loops=1)
        ->  Aggregate  (cost=19.13..19.14 rows=1 width=128) (actual time=0.104..0.104 rows=1 loops=1)
              ->  HashAggregate  (cost=14.63..16.62 rows=200 width=548) (actual time=0.100..0.101 rows=10 loops=1)
                    Group Key: cte_3.name
                    Batches: 1  Memory Usage: 40kB
                    ->  CTE Scan on cte cte_3  (cost=0.00..11.70 rows=585 width=548) (actual time=0.000..0.020 rows=439 loops=1)
Planning Time: 0.582 ms
Execution Time: 1.466 ms
```

### Result

A bit tougher readability but the cost shifted down and we get a lots of info for relatively small cost.