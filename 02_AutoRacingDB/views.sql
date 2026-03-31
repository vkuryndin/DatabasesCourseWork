--VIEW 1
-- Представление со статистикой по машинам

CREATE VIEW car_race_stats_view AS
SELECT
    c.name AS car_name,
    c.class AS car_class,
    cl.country AS car_country,
    AVG(r.position::NUMERIC) AS average_position,
    COUNT(*) AS race_count
FROM Cars c
         JOIN Results r ON r.car = c.name
         JOIN Classes cl ON cl.class = c.class
GROUP BY c.name, c.class, cl.country;