--ЗАДАЧА 1
-- Определить, какие клиенты сделали более двух бронирований в разных отелях,
-- и вывести информацию о каждом таком клиенте, включая его имя, электронную почту,
-- телефон, общее количество бронирований, а также список отелей,
-- в которых они бронировали номера (объединенные в одно поле через запятую).
-- Также подсчитать среднюю длительность их пребывания (в днях) по всем бронированиям.
-- Отсортировать результаты по количеству бронирований в порядке убывания.

-- РЕШЕНИЕ 1
SELECT c.name,
       c.email,
       c.phone,
       COUNT(*) AS total_bookings,
       STRING_AGG(DISTINCT h.name, ', ' ORDER BY h.name) AS hotel_list,
       ROUND(AVG(b.check_out_date - b.check_in_date), 4) AS average_stay_days
FROM Customer c
         JOIN Booking b ON b.ID_customer = c.ID_customer
         JOIN Room r ON r.ID_room = b.ID_room
         JOIN Hotel h ON h.ID_hotel = r.ID_hotel
GROUP BY c.ID_customer, c.name, c.email, c.phone
HAVING COUNT(*) > 2
   AND COUNT(DISTINCT h.ID_hotel) > 1
ORDER BY total_bookings DESC, c.name;


--ЗАДАЧА 2
-- Необходимо провести анализ клиентов, которые сделали более двух бронирований в разных отелях
-- и потратили более 500 долларов на свои бронирования. Для этого:
--  Определить клиентов, которые сделали более двух бронирований и забронировали номера в более чем одном отеле.
--  Вывести для каждого такого клиента следующие данные: ID_customer, имя, общее количество бронирований,
--  общее количество уникальных отелей, в которых они бронировали номера, и общую сумму, потраченную на бронирования.
--
-- Также определить клиентов, которые потратили более 500 долларов на бронирования, и вывести для них
-- ID_customer, имя, общую сумму, потраченную на бронирования, и общее количество бронирований.
--
-- В результате объединить данные из первых двух пунктов, чтобы получить список клиентов,
-- которые соответствуют условиям обоих запросов. Отобразить поля: ID_customer, имя, общее количество бронирований, общую сумму, потраченную на бронирования, и общее количество уникальных отелей.
--
-- Результаты отсортировать по общей сумме, потраченной клиентами, в порядке возрастания.

--РЕШЕНИЕ 2
WITH customer_stats AS (
    SELECT c.ID_customer,
           c.name,
           COUNT(*) AS total_bookings,
           COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
           SUM(r.price) AS total_spent
    FROM Customer c
             JOIN Booking b ON b.ID_customer = c.ID_customer
             JOIN Room r ON r.ID_room = b.ID_room
             JOIN Hotel h ON h.ID_hotel = r.ID_hotel
    GROUP BY c.ID_customer, c.name
),
     frequent_customers AS (
         SELECT ID_customer,
                name,
                total_bookings,
                unique_hotels,
                total_spent
         FROM customer_stats
         WHERE total_bookings > 2
           AND unique_hotels > 1
     ),
     big_spenders AS (
         SELECT ID_customer,
                name,
                total_bookings,
                unique_hotels,
                total_spent
         FROM customer_stats
         WHERE total_spent > 500
     )
SELECT fc.ID_customer,
       fc.name,
       fc.total_bookings,
       fc.total_spent,
       fc.unique_hotels
FROM frequent_customers fc

         JOIN big_spenders bs ON bs.ID_customer = fc.ID_customer

ORDER BY fc.total_spent ASC;



--ЗАДАЧА 3
-- Вам необходимо провести анализ данных о бронированиях в отелях и определить предпочтения клиентов по типу отелей.
-- Для этого выполните следующие шаги:
--
--  1. Категоризация отелей.
--     Определите категорию каждого отеля на основе средней стоимости номера:
--     «Дешевый»: средняя стоимость менее 175 долларов.
--     «Средний»: средняя стоимость от 175 до 300 долларов.
--     «Дорогой»: средняя стоимость более 300 долларов.
-- 2. Анализ предпочтений клиентов.
--    Для каждого клиента определите предпочитаемый тип отеля на основании условия ниже:
--     Если у клиента есть хотя бы один «дорогой» отель, присвойте ему категорию «дорогой».
--     Если у клиента нет «дорогих» отелей, но есть хотя бы один «средний», присвойте ему категорию «средний».
--     Если у клиента нет «дорогих» и «средних» отелей, но есть «дешевые»,
--     присвойте ему категорию предпочитаемых отелей «дешевый».

-- 3. Вывод информации.
--   Выведите для каждого клиента следующую информацию:
--    ID_customer: уникальный идентификатор клиента.
--    name: имя клиента.
--    preferred_hotel_type: предпочитаемый тип отеля.
--    visited_hotels: список уникальных отелей, которые посетил клиент.

-- 4. Сортировка результатов.
--    Отсортируйте клиентов так, чтобы сначала шли клиенты с «дешевыми» отелями, затем со «средними» и в конце — с «дорогими».

--РЕШЕНИЕ 3
WITH hotel_categories AS (
    SELECT h.ID_hotel,
           h.name AS hotel_name,
           CASE
               WHEN AVG(r.price) < 175 THEN 'Дешевый'
               WHEN AVG(r.price) <= 300 THEN 'Средний'
               ELSE 'Дорогой'
               END AS hotel_type
    FROM Hotel h
             JOIN Room r ON r.ID_hotel = h.ID_hotel
    GROUP BY h.ID_hotel, h.name
),
     customer_preferences AS (
         SELECT c.ID_customer,
                c.name,
                CASE
                    WHEN BOOL_OR(hc.hotel_type = 'Дорогой') THEN 'Дорогой'
                    WHEN BOOL_OR(hc.hotel_type = 'Средний') THEN 'Средний'
                    ELSE 'Дешевый'
                    END AS preferred_hotel_type,
                STRING_AGG(DISTINCT hc.hotel_name, ',' ORDER BY hc.hotel_name) AS visited_hotels
         FROM Customer c
                  JOIN Booking b ON b.ID_customer = c.ID_customer
                  JOIN Room r ON r.ID_room = b.ID_room
                  JOIN hotel_categories hc ON hc.ID_hotel = r.ID_hotel
         GROUP BY c.ID_customer, c.name
     )
SELECT ID_customer,
       name,
       preferred_hotel_type,
       visited_hotels
FROM customer_preferences
ORDER BY ARRAY_POSITION(ARRAY['Дешевый', 'Средний', 'Дорогой'], preferred_hotel_type),
         ID_customer;