-- TASK 1
-- Определить, какие автомобили из каждого класса имеют наименьшую среднюю позицию в гонках,
-- и вывести информацию о каждом таком автомобиле для данного класса, включая его класс,
-- среднюю позицию и количество гонок, в которых он участвовал.
-- Также отсортировать результаты по средней позиции.

--SOLUTION
WITH car_stats AS (
    SELECT c.name AS car_name,
           c.class AS car_class,
           cl.country AS car_country,
           AVG(r.position::NUMERIC) AS average_position,
           COUNT(*) AS race_count
    FROM Cars c
             JOIN Results r ON r.car = c.name
             JOIN Classes cl ON cl.class = c.class
    GROUP BY c.name, c.class, cl.country
)

SELECT car_name,
       car_class,
       ROUND(average_position, 4) AS average_position,
       race_count,
       car_country
FROM car_stats
ORDER BY average_position, car_name
LIMIT 1;

--TASK 2
-- Определить автомобиль, который имеет наименьшую среднюю позицию в гонках среди всех автомобилей,
-- и вывести информацию об этом автомобиле, включая его класс, среднюю позицию,
-- количество гонок, в которых он участвовал, и страну производства класса автомобиля.
-- Если несколько автомобилей имеют одинаковую наименьшую среднюю позицию,
-- выбрать один из них по алфавиту (по имени автомобиля).

--SOLUTION

WITH car_stats AS (
    SELECT c.name AS car_name,
           c.class AS car_class,
           c.year,
           AVG(r.position::NUMERIC) AS average_position,
           COUNT(*) AS race_count
    FROM Cars c

          JOIN Results r ON r.car = c.name
    GROUP BY c.name, c.class, c.year
),

     best_in_class AS (
         SELECT car_class,
                MIN(average_position) AS best_average_position
         FROM car_stats
         GROUP BY car_class
     )

SELECT cs.car_name,
       cs.car_class,
       ROUND(cs.average_position, 4) AS average_position,
       cs.race_count
FROM car_stats cs

         JOIN best_in_class bc
              ON bc.car_class = cs.car_class
                  AND bc.best_average_position = cs.average_position

ORDER BY cs.average_position, cs.year;

--TASK 3
-- Определить классы автомобилей, которые имеют наименьшую среднюю позицию в гонках,
-- и вывести информацию о каждом автомобиле из этих классов, включая его имя,
-- среднюю позицию, количество гонок, в которых он участвовал,
-- страну производства класса автомобиля, а также общее количество гонок,
-- в которых участвовали автомобили этих классов. Если несколько классов
-- имеют одинаковую среднюю позицию, выбрать все из них.

--SOLUTION

WITH car_stats AS (
    SELECT c.name AS car_name,
           c.class AS car_class,
           cl.country AS car_country,
           AVG(r.position::NUMERIC) AS average_position,
           COUNT(*) AS race_count
    FROM Cars c

             JOIN Results r ON r.car = c.name

             JOIN Classes cl ON cl.class = c.class
    GROUP BY c.name, c.class, cl.country
),

     class_stats AS (
         SELECT c.class AS car_class,
                AVG(r.position::NUMERIC) AS class_average_position,
                COUNT(*) AS total_races
         FROM Cars c

                  JOIN Results r ON r.car = c.name
         GROUP BY c.class
     ),

     best_classes AS (
         SELECT car_class, total_races
         FROM class_stats
         WHERE class_average_position = (
             SELECT MIN(class_average_position)
             FROM class_stats
         )
     )

SELECT cs.car_name,
       cs.car_class,
       ROUND(cs.average_position, 4) AS average_position,
       cs.race_count,
       cs.car_country,
       bc.total_races
FROM car_stats cs

         JOIN best_classes bc ON bc.car_class = cs.car_class

ORDER BY cs.average_position, cs.car_name;

-- TASK 4
-- Определить, какие автомобили имеют среднюю позицию лучше (меньше) средней позиции всех автомобилей в своем классе
-- (то есть автомобилей в классе должно быть минимум два, чтобы выбрать один из них).
-- Вывести информацию об этих автомобилях, включая их имя, класс, среднюю позицию,
-- количество гонок, в которых они участвовали, и страну производства класса автомобиля.
-- Также отсортировать результаты по классу и затем по средней позиции в порядке возрастания.

--SOLUTION

WITH car_stats AS (
    SELECT c.name AS car_name,
           c.class AS car_class,
           cl.country AS car_country,
           AVG(r.position::NUMERIC) AS average_position,
           COUNT(*) AS race_count
    FROM Cars c

             JOIN Results r ON r.car = c.name

             JOIN Classes cl ON cl.class = c.class
    GROUP BY c.name, c.class, cl.country
),

     class_stats AS (
         SELECT car_class,
                AVG(average_position) AS class_average_position,
                COUNT(*) AS class_car_count
         FROM car_stats
         GROUP BY car_class
     )

SELECT cs.car_name,
       cs.car_class,
       ROUND(cs.average_position, 4) AS average_position,
       cs.race_count,
       cs.car_country
FROM car_stats cs

         JOIN class_stats cls ON cls.car_class = cs.car_class
WHERE cls.class_car_count >= 2
  AND cs.average_position < cls.class_average_position

ORDER BY cs.car_class, cs.average_position;

--TASK 5
--Определить, какие классы автомобилей имеют наибольшее количество автомобилей с низкой средней позицией (больше 3.0)
--и вывести информацию о каждом автомобиле из этих классов, включая его имя, класс, среднюю позицию, количество гонок,
--в которых он участвовал, страну производства класса автомобиля, а также общее количество гонок для каждого класса.
--Отсортировать результаты по количеству автомобилей с низкой средней позицией

--Тут в итоге будет два варианта:
-- 1. Вариант с точным соответствием эталонному выводу, который есть в постановке задачи
-- 2. Вариант с точным соответствием постановке задачи.
--SOLUTION Вариант1
WITH car_stats AS (
    SELECT c.name AS car_name,
           c.class AS car_class,
           cl.country AS car_country,
           AVG(r.position::NUMERIC) AS average_position,
           COUNT(*) AS race_count
    FROM Cars c
             JOIN Results r ON r.car = c.name
             JOIN Classes cl ON cl.class = c.class
    GROUP BY c.name, c.class, cl.country
),
     class_stats AS (
         SELECT car_class,
                SUM(race_count) AS total_races,
                COUNT(*) FILTER (WHERE average_position >= 3.0) AS low_position_count
         FROM car_stats
         GROUP BY car_class
     )

SELECT cs.car_name,
       cs.car_class,
       ROUND(cs.average_position, 4) AS average_position,
       cs.race_count,
       cs.car_country,
       cls.total_races,
       cls.low_position_count
FROM car_stats cs

         JOIN class_stats cls ON cls.car_class = cs.car_class
WHERE cs.average_position > 3.0

ORDER BY cls.low_position_count DESC, cs.car_class, cs.average_position;

--SOLUTION Вариант 2

WITH car_stats AS (
    SELECT c.name AS car_name,
           c.class AS car_class,
           cl.country AS car_country,
           AVG(r.position::NUMERIC) AS average_position,
           COUNT(*) AS race_count
    FROM Cars c
             JOIN Results r ON r.car = c.name
             JOIN Classes cl ON cl.class = c.class
    GROUP BY c.name, c.class, cl.country
),
     class_stats AS (
         SELECT car_class,
                SUM(race_count) AS total_races,
                COUNT(*) FILTER (WHERE average_position > 3.0) AS low_position_count
         FROM car_stats
         GROUP BY car_class
     ),
     max_low_position AS (
         SELECT MAX(low_position_count) AS max_count
         FROM class_stats
     )
SELECT cs.car_name,
       cs.car_class,
       ROUND(cs.average_position, 4) AS average_position,
       cs.race_count,
       cs.car_country,
       cls.total_races,
       cls.low_position_count
FROM car_stats cs
         JOIN class_stats cls ON cls.car_class = cs.car_class
         JOIN max_low_position mlp ON cls.low_position_count = mlp.max_count
WHERE cls.low_position_count > 0
ORDER BY cls.low_position_count DESC, cs.car_class, cs.car_name;

