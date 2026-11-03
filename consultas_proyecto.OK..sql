/*
DataProject: Lógica de Consultas SQL
Base de datos: Sakila (PostgreSQL)
Archivo de resolución de los ejercicios 1–64.

*/
=========================================================
-- 1. Base de datos
-- La base sakila ya existe en PostgreSQL. Ejecuta este archivo conectado a ella.
-- PostgreSQL no utiliza USE sakila; la conexión determina la base de datos activa.
-- =========================================================

-- =========================================================
-- 2. Nombres de películas con clasificación R
-- =========================================================
SELECT title
FROM film
WHERE rating = 'R';

-- =========================================================
-- 3. Actores con actor_id entre 30 y 40 (incluidos)
-- =========================================================
SELECT first_name, last_name
FROM actor
WHERE actor_id BETWEEN 30 AND 40;

-- =========================================================
-- 4. Películas cuyo idioma coincide con el idioma original
-- =========================================================
SELECT f.title
FROM film AS f
WHERE f.language_id = f.original_language_id;

-- =========================================================
-- 5. Películas ordenadas por duración ascendente
-- =========================================================
SELECT title, length
FROM film
ORDER BY length ASC;

-- =========================================================
-- 6. Actores cuyo apellido contiene 'Allen'
-- =========================================================
SELECT first_name, last_name
FROM actor
WHERE last_name ILIKE '%allen%';

-- =========================================================
-- 7. Número de películas por clasificación
-- =========================================================
SELECT rating, COUNT(*) AS total_peliculas
FROM film
GROUP BY rating
ORDER BY rating;

-- =========================================================
-- 8. Películas clasificadas PG-13 o con duración mayor a 3 horas
-- =========================================================
SELECT title, rating, length
FROM film
WHERE rating = 'PG-13'
   OR length > 180;

-- =========================================================
-- 9. Variabilidad del coste de reemplazo de las películas
-- Se utiliza la desviación estándar poblacional.
-- =========================================================
SELECT STDDEV_POP(replacement_cost) AS desviacion_estandar_coste_reemplazo
FROM film;

-- =========================================================
-- 10. Mayor y menor duración de película
-- =========================================================
SELECT MAX(length) AS duracion_maxima,
       MIN(length) AS duracion_minima
FROM film;


-- =========================================================
-- 11. Coste del antepenúltimo alquiler por fecha
-- Se toma el importe del pago asociado a cada alquiler.
-- =========================================================
SELECT r.rental_id, r.rental_date, p.amount
FROM rental AS r
JOIN payment AS p
  ON p.rental_id = r.rental_id
ORDER BY r.rental_date DESC, r.rental_id DESC
LIMIT 1 OFFSET 2;

-- =========================================================
-- 12. Películas cuya clasificación no es NC-17 ni G
-- =========================================================
SELECT title
FROM film
WHERE rating NOT IN ('NC-17', 'G');

-- =========================================================
-- 13. Duración media por clasificación
-- =========================================================
SELECT rating, AVG(length) AS duracion_media
FROM film
GROUP BY rating
ORDER BY rating;

-- =========================================================
-- 14. Películas con duración superior a 180 minutos
-- =========================================================
SELECT title, length
FROM film
WHERE length > 180
ORDER BY length DESC;

-- =========================================================
-- 15. Ingresos totales de la empresa (suma de pagos registrados)
-- =========================================================
SELECT SUM(amount) AS ingresos_totales
FROM payment;

-- =========================================================
-- 16. Los 10 clientes con mayor customer_id
-- =========================================================
SELECT customer_id, first_name, last_name
FROM customer
ORDER BY customer_id DESC
LIMIT 10;

-- =========================================================
-- 17. Actores que aparecen en la película 'Egg Igby'
-- =========================================================
SELECT a.first_name, a.last_name
FROM actor AS a
JOIN film_actor AS fa ON fa.actor_id = a.actor_id
JOIN film AS f ON f.film_id = fa.film_id
WHERE f.title = 'Egg Igby'
ORDER BY a.last_name, a.first_name;

-- =========================================================
-- 18. Títulos de películas únicos
-- En Sakila, title suele ser único; DISTINCT cumple la consigna.
-- =========================================================
SELECT DISTINCT title
FROM film
ORDER BY title;

-- =========================================================
-- 19. Comedias con duración superior a 180 minutos
-- =========================================================
SELECT DISTINCT f.title, f.length
FROM film AS f
JOIN film_category AS fc ON fc.film_id = f.film_id
JOIN category AS c ON c.category_id = fc.category_id
WHERE c.name = 'Comedy'
  AND f.length > 180
ORDER BY f.title;

-- =========================================================
-- 20. Categorías con duración media superior a 110 minutos
-- =========================================================
SELECT c.name AS categoria,
       AVG(f.length) AS duracion_media
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN film AS f ON f.film_id = fc.film_id
GROUP BY c.category_id, c.name
HAVING AVG(f.length) > 110
ORDER BY duracion_media DESC;

-- =========================================================
-- EJERCICIO 21
-- ¿Cuál es la media de duración del alquiler de las películas?
-- Se consideran únicamente los alquileres devueltos, ya que son los únicos cuya duración real se conoce
-- =========================================================

SELECT
    AVG(return_date - rental_date) AS promedio_duracion_alquiler
FROM rental
WHERE return_date IS NOT NULL;

-- =========================================================
-- 22. Nombre completo de todos los actores y actrices
-- =========================================================
SELECT actor_id,
       CONCAT(first_name, ' ', last_name) AS nombre_completo
FROM actor
ORDER BY last_name, first_name;

-- =========================================================
-- 23. Número de alquileres por día, descendente por cantidad
-- =========================================================
SELECT DATE(rental_date) AS dia,
       COUNT(*) AS numero_alquileres
FROM rental
GROUP BY DATE(rental_date)
ORDER BY numero_alquileres DESC, dia ASC;

-- =========================================================
-- 24. Películas cuya duración supera la duración media de todas
-- =========================================================
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;

-- =========================================================
-- 25. Número de alquileres por mes (año y mes)
-- =========================================================
SELECT TO_CHAR(rental_date, 'YYYY-MM') AS anio_mes,
       COUNT(*) AS numero_alquileres
FROM rental
GROUP BY TO_CHAR(rental_date, 'YYYY-MM')
ORDER BY anio_mes;

-- =========================================================
-- 26. Promedio, desviación estándar y varianza del total pagado
-- =========================================================
SELECT AVG(amount) AS promedio_pagado,
       STDDEV_POP(amount) AS desviacion_estandar_pagado,
       VAR_POP(amount) AS varianza_pagado
FROM payment;

-- =========================================================
-- 27. Películas con tarifa de alquiler por encima de la media
-- =========================================================
SELECT title, rental_rate
FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film)
ORDER BY rental_rate DESC, title;

-- =========================================================
-- 28. IDs de actores que han participado en más de 40 películas
-- =========================================================
SELECT actor_id, COUNT(DISTINCT film_id) AS total_peliculas
FROM film_actor
GROUP BY actor_id
HAVING COUNT(DISTINCT film_id) > 40
ORDER BY total_peliculas DESC;

-- =========================================================
--- EJERCICIO 29
-- Obtener todas las películas y, si están disponibles en el inventario,
-- mostrar la cantidad disponible.
-- =========================================================

SELECT
    f.film_id,
    f.title,
    COUNT(i.inventory_id) FILTER (
        WHERE NOT EXISTS (
            SELECT 1
            FROM rental r
            WHERE r.inventory_id = i.inventory_id
              AND r.return_date IS NULL
        )
    ) AS cantidad_disponible
FROM film f
LEFT JOIN inventory i
    ON f.film_id = i.film_id
GROUP BY f.film_id, f.title
ORDER BY f.title;

-- =========================================================
-- 30. Actores y número de películas en las que han actuado
-- =========================================================
SELECT a.actor_id, a.first_name, a.last_name,
       COUNT(fa.film_id) AS numero_peliculas
FROM actor AS a
LEFT JOIN film_actor AS fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY numero_peliculas DESC, a.last_name;

-- =========================================================
-- 31. Todas las películas y sus actores, incluso sin actores asociados
-- =========================================================
SELECT f.film_id, f.title, a.actor_id, a.first_name, a.last_name
FROM film AS f
LEFT JOIN film_actor AS fa ON fa.film_id = f.film_id
LEFT JOIN actor AS a ON a.actor_id = fa.actor_id
ORDER BY f.title, a.last_name, a.first_name;

-- =========================================================
-- 32. Todos los actores y las películas en las que actuaron
-- Incluye actores sin películas, si existieran.
-- =========================================================
SELECT a.actor_id, a.first_name, a.last_name, f.film_id, f.title
FROM actor AS a
LEFT JOIN film_actor AS fa ON fa.actor_id = a.actor_id
LEFT JOIN film AS f ON f.film_id = fa.film_id
ORDER BY a.last_name, a.first_name, f.title;

-- =========================================================
-- 33. Todas las películas y todos los registros de alquiler
-- PostgreSQL admite FULL OUTER JOIN. Se incluyen todas las películas,
-- copias de inventario y alquileres, incluso si falta una relación.
-- =========================================================
SELECT f.film_id, f.title, i.inventory_id, r.rental_id, r.rental_date
FROM film AS f
FULL OUTER JOIN inventory AS i ON i.film_id = f.film_id
FULL OUTER JOIN rental AS r ON r.inventory_id = i.inventory_id;

-- =========================================================
-- 34. Los 5 clientes que más dinero han gastado
-- =========================================================
SELECT c.customer_id, c.first_name, c.last_name,
       SUM(p.amount) AS total_gastado
FROM customer AS c
JOIN payment AS p ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_gastado DESC
LIMIT 5;

-- =========================================================
-- 35. Actores cuyo nombre es Johnny
-- =========================================================
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Johnny';

-- =========================================================
-- 36. Renombrar first_name como Nombre y last_name como Apellido
-- =========================================================
SELECT first_name AS Nombre,
       last_name AS Apellido
FROM actor;

-- =========================================================
-- 37. ID de actor más bajo y más alto
-- =========================================================
SELECT MIN(actor_id) AS id_mas_bajo,
       MAX(actor_id) AS id_mas_alto
FROM actor;

-- =========================================================
-- 38. Número total de actores
-- =========================================================
SELECT COUNT(*) AS total_actores
FROM actor;

-- =========================================================
-- 39. Todos los actores ordenados por apellido ascendente
-- =========================================================
SELECT actor_id, first_name, last_name
FROM actor
ORDER BY last_name ASC, first_name ASC;

-- =========================================================
-- 40. Primeras 5 películas de la tabla film
-- Se ordenan por film_id para que el resultado sea reproducible.
-- =========================================================
SELECT *
FROM film
ORDER BY film_id
LIMIT 5;

-- =========================================================
-- 41. Cantidad de actores por nombre; primero el nombre más repetido
-- =========================================================
SELECT first_name, COUNT(*) AS cantidad_actores
FROM actor
GROUP BY first_name
ORDER BY cantidad_actores DESC, first_name ASC;

-- =========================================================
-- 42. Todos los alquileres y los nombres de los clientes
-- =========================================================
SELECT r.rental_id, r.rental_date, c.customer_id,
       c.first_name, c.last_name
FROM rental AS r
JOIN customer AS c ON c.customer_id = r.customer_id
ORDER BY r.rental_date;

-- =========================================================
-- 43. Todos los clientes y sus alquileres, incluidos sin alquileres
-- =========================================================
SELECT c.customer_id, c.first_name, c.last_name,
       r.rental_id, r.rental_date
FROM customer AS c
LEFT JOIN rental AS r ON r.customer_id = c.customer_id
ORDER BY c.customer_id, r.rental_date;

-- =========================================================
-- 44. CROSS JOIN entre film y category
-- Genera todas las combinaciones posibles; normalmente no aporta
-- una relación real entre películas y categorías.
-- =========================================================
SELECT f.title, c.name AS categoria
FROM film AS f
CROSS JOIN category AS c;

-- Respuesta 44:
-- Esta consulta combina cada película con cada categoría, aunque no exista
-- una relación real entre ellas. No es útil para conocer la categoría real
-- de una película; para eso deben usarse film_category y category.

-- =========================================================
-- 45. Actores que participaron en películas de la categoría Action
-- =========================================================
SELECT DISTINCT a.actor_id, a.first_name, a.last_name
FROM actor AS a
JOIN film_actor AS fa ON fa.actor_id = a.actor_id
JOIN film_category AS fc ON fc.film_id = fa.film_id
JOIN category AS c ON c.category_id = fc.category_id
WHERE c.name = 'Action'
ORDER BY a.last_name, a.first_name;

-- =========================================================
-- 46. Actores que no han participado en ninguna película
-- =========================================================
SELECT a.actor_id, a.first_name, a.last_name
FROM actor AS a
LEFT JOIN film_actor AS fa ON fa.actor_id = a.actor_id
WHERE fa.film_id IS NULL;

-- =========================================================
-- 47. Nombre de actores y cantidad de películas
-- =========================================================
SELECT a.first_name, a.last_name,
       COUNT(fa.film_id) AS cantidad_peliculas
FROM actor AS a
LEFT JOIN film_actor AS fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY cantidad_peliculas DESC, a.last_name;

-- =========================================================
-- 48. Vista actor_num_peliculas
-- Si ya existe, se reemplaza.
-- =========================================================
CREATE OR REPLACE VIEW actor_num_peliculas AS
SELECT a.actor_id, a.first_name, a.last_name,
       COUNT(fa.film_id) AS numero_peliculas
FROM actor AS a
LEFT JOIN film_actor AS fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name;

-- Consultar la vista creada:
SELECT *
FROM actor_num_peliculas
ORDER BY numero_peliculas DESC, last_name;

-- =========================================================
-- 49. Número total de alquileres por cliente
-- =========================================================
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(r.rental_id) AS total_alquileres
FROM customer AS c
LEFT JOIN rental AS r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_alquileres DESC;

-- =========================================================
-- 50. Duración total de las películas de la categoría Action
-- =========================================================
SELECT c.name AS categoria,
       SUM(f.length) AS duracion_total_minutos
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN film AS f ON f.film_id = fc.film_id
WHERE c.name = 'Action'
GROUP BY c.name;

-- =========================================================
-- 51. Tabla temporal con total de alquileres por cliente
-- Se crea como tabla temporal y existe solo durante la sesión/conexión actual.
-- =========================================================
DROP TABLE IF EXISTS cliente_rentas_temporal;

CREATE TEMPORARY TABLE cliente_rentas_temporal AS
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(r.rental_id) AS total_alquileres
FROM customer AS c
LEFT JOIN rental AS r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

SELECT *
FROM cliente_rentas_temporal
ORDER BY total_alquileres DESC;

-- =========================================================
-- 52. Tabla temporal de películas alquiladas al menos 10 veces
-- =========================================================
DROP TABLE IF EXISTS peliculas_alquiladas;

CREATE TEMPORARY TABLE peliculas_alquiladas AS
SELECT f.film_id, f.title,
       COUNT(r.rental_id) AS veces_alquilada
FROM film AS f
JOIN inventory AS i ON i.film_id = f.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
GROUP BY f.film_id, f.title
HAVING COUNT(r.rental_id) >= 10;

SELECT *
FROM peliculas_alquiladas
ORDER BY veces_alquilada DESC, title;


-- =========================================================
-- 53. Películas alquiladas por Tammy Sanders que aún no se devolvieron
-- =========================================================
SELECT DISTINCT f.title
FROM customer AS c
JOIN rental AS r ON r.customer_id = c.customer_id
JOIN inventory AS i ON i.inventory_id = r.inventory_id
JOIN film AS f ON f.film_id = i.film_id
WHERE c.first_name = 'Tammy'
  AND c.last_name = 'Sanders'
  AND r.return_date IS NULL
ORDER BY f.title;

-- =========================================================
-- 54. Actores con al menos una película de categoría Sci-Fi
-- =========================================================
SELECT DISTINCT a.actor_id, a.first_name, a.last_name
FROM actor AS a
JOIN film_actor AS fa ON fa.actor_id = a.actor_id
JOIN film_category AS fc ON fc.film_id = fa.film_id
JOIN category AS c ON c.category_id = fc.category_id
WHERE c.name = 'Sci-Fi'
ORDER BY a.last_name, a.first_name;

-- =========================================================
-- 55. Actores de películas alquiladas después del primer alquiler
-- de 'Spartacus Cheaper'
-- =========================================================
SELECT DISTINCT a.actor_id, a.first_name, a.last_name
FROM actor AS a
JOIN film_actor AS fa ON fa.actor_id = a.actor_id
JOIN inventory AS i ON i.film_id = fa.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
WHERE r.rental_date > (
    SELECT MIN(r2.rental_date)
    FROM rental AS r2
    JOIN inventory AS i2 ON i2.inventory_id = r2.inventory_id
    JOIN film AS f2 ON f2.film_id = i2.film_id
    WHERE f2.title = 'SPARTACUS CHEAPER'
)
ORDER BY a.last_name, a.first_name;

-- =========================================================
-- 56. Actores que no han actuado en ninguna película de categoría Music
-- =========================================================
SELECT a.actor_id, a.first_name, a.last_name
FROM actor AS a
WHERE NOT EXISTS (
    SELECT 1
    FROM film_actor AS fa
    JOIN film_category AS fc ON fc.film_id = fa.film_id
    JOIN category AS c ON c.category_id = fc.category_id
    WHERE fa.actor_id = a.actor_id
      AND c.name = 'Music'
)
ORDER BY a.last_name, a.first_name;

-- =========================================================
-- 57. Películas alquiladas por más de 8 días
-- Se calcula la diferencia entre fecha de devolución y alquiler.
-- Los alquileres sin devolución no pueden evaluarse con esta condición.
-- =========================================================
SELECT DISTINCT f.title
FROM film AS f
JOIN inventory AS i ON i.film_id = f.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
WHERE r.return_date IS NOT NULL
  AND (r.return_date::date - r.rental_date::date) > 8
ORDER BY f.title;

-- =========================================================
-- 58. Películas de la categoría Animation
-- =========================================================
SELECT DISTINCT f.title
FROM film AS f
JOIN film_category AS fc ON fc.film_id = f.film_id
JOIN category AS c ON c.category_id = fc.category_id
WHERE c.name = 'Animation'
ORDER BY f.title;

-- =========================================================
-- 59. Películas con la misma duración que 'Dancing Fever'
-- =========================================================
SELECT title, length
FROM film
WHERE length = (
    SELECT length
    FROM film
    WHERE title = 'DANCING FEVER'
    LIMIT 1
)
ORDER BY title;

-- =========================================================
-- 60. Clientes que alquilaron al menos 7 películas distintas
-- =========================================================
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(DISTINCT f.film_id) AS peliculas_distintas
FROM customer AS c
JOIN rental AS r ON r.customer_id = c.customer_id
JOIN inventory AS i ON i.inventory_id = r.inventory_id
JOIN film AS f ON f.film_id = i.film_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT f.film_id) >= 7
ORDER BY c.last_name, c.first_name;

-- =========================================================
-- 61. Cantidad de alquileres por categoría
-- =========================================================
SELECT c.name AS categoria,
       COUNT(r.rental_id) AS total_alquileres
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN inventory AS i ON i.film_id = fc.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
GROUP BY c.category_id, c.name
ORDER BY total_alquileres DESC, c.name;

-- =========================================================
-- 62. Número de películas por categoría estrenadas en 2006
-- =========================================================
SELECT c.name AS categoria,
       COUNT(DISTINCT f.film_id) AS numero_peliculas
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN film AS f ON f.film_id = fc.film_id
WHERE f.release_year = 2006
GROUP BY c.category_id, c.name
ORDER BY c.name;

-- =========================================================
-- 63. Todas las combinaciones posibles de trabajadores y tiendas
-- =========================================================
SELECT s.staff_id, s.first_name, s.last_name,
       st.store_id
FROM staff AS s
CROSS JOIN store AS st
ORDER BY s.staff_id, st.store_id;

-- =========================================================
-- 64. Total de alquileres por cliente: ID, nombre, apellido y cantidad
-- =========================================================
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(r.rental_id) AS total_peliculas_alquiladas
FROM customer AS c
LEFT JOIN rental AS r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY c.customer_id;


