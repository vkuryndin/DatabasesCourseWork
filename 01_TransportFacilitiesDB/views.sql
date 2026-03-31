-- VIEW 1
-- Общее представление для всех типов транспорта
CREATE VIEW all_vehicles_view AS
SELECT
    v.maker,
    c.model,
    c.horsepower,
    c.engine_capacity,
    c.price,
    'Car' AS vehicle_type
FROM Vehicle v
         JOIN Car c ON c.model = v.model

UNION ALL

SELECT
    v.maker,
    m.model,
    m.horsepower,
    m.engine_capacity,
    m.price,
    'Motorcycle' AS vehicle_type
FROM Vehicle v
         JOIN Motorcycle m ON m.model = v.model

UNION ALL

SELECT
    v.maker,
    b.model,
    NULL AS horsepower,
    NULL AS engine_capacity,
    b.price,
    'Bicycle' AS vehicle_type
FROM Vehicle v
         JOIN Bicycle b ON b.model = v.model;