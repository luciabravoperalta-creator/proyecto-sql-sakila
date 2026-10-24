/*
DataProject: Lógica de Consultas SQL
Base de datos: Sakila (PostgreSQL)
Archivo de resolución de los ejercicios 1–64.

*/

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

-- 6. Actores cuyo apellido contiene 'Allen'
-- =========================================================
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%Allen%';

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
    WHERE f2.title = 'Spartacus Cheaper'
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
    WHERE title = 'Dancing Fever'
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


