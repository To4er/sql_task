SELECT c.name, COUNT(f.film_id)
FROM film_category fc
JOIN category c USING (category_id)
JOIN film f USING (film_id)
GROUP BY c.name
ORDER BY COUNT(f.film_id) DESC

SELECT CONCAT(a.first_name,' ', a.last_name) AS actor, SUM(f.rental_duration)
FROM film_actor
JOIN actor a USING (actor_id)
JOIN film f USING (film_id)
GROUP BY a.actor_id
ORDER BY SUM(f.rental_duration) DESC
LIMIT 10

SELECT f.title, inventory_id
FROM inventory i
RIGHT JOIN film f USING (film_id)
WHERE inventory_id IS NULL

WITH actor_count AS (
	SELECT 
		CONCAT(a.first_name,' ',a.last_name) AS full_name,
		COUNT(*) AS films_amount,
		DENSE_RANK() OVER (ORDER BY COUNT(film_id) DESC) AS rank_position
	FROM film_category fc
	JOIN film f USING(film_id)
	JOIN film_actor fa USING(film_id)
	JOIN category c USING (category_id)
	JOIN actor a USING(actor_id)
	WHERE c.name = 'Children'
	GROUP BY a.actor_id)
SELECT 
	full_name,
	films_amount,
	rank_position
FROM actor_count
WHERE rank_position <= 3

SELECT 
    cl.city,
    COUNT(CASE WHEN cus.active = 1 THEN 1 END) AS active_customers,
    COUNT(CASE WHEN cus.active = 0 THEN 1 END) AS inactive_customers
FROM 
    customer_list cl
    JOIN city c USING (city)
    JOIN customer cus ON cl.id = cus.customer_id 
GROUP BY 
    c.city_id, cl.city
ORDER BY 
    inactive_customers DESC;

WITH RentalDetails AS (
    SELECT
        c.name AS category_name,
        ci.city,
        EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600 AS rental_hours
    FROM
        category c
    JOIN
        film_category fc ON c.category_id = fc.category_id
    JOIN
        film f ON fc.film_id = f.film_id
    JOIN
        inventory i ON f.film_id = i.film_id
    JOIN
        rental r ON i.inventory_id = r.inventory_id
    JOIN
        customer cu ON r.customer_id = cu.customer_id
    JOIN
        address a ON cu.address_id = a.address_id
    JOIN
        city ci ON a.city_id = ci.city_id
    WHERE
        r.return_date IS NOT NULL
)

(
    SELECT
        'Города на "a"' AS city_group,
        category_name,
        SUM(rental_hours) AS total_rental_hours
    FROM
        RentalDetails
    WHERE
        city LIKE 'a%'
    GROUP BY
        category_name
    ORDER BY
        total_rental_hours DESC
    LIMIT 1 
)

UNION ALL

(
    SELECT
        'Города с "-"' AS city_group,
        category_name,
        SUM(rental_hours) AS total_rental_hours
    FROM
        RentalDetails
    WHERE
        city LIKE '%-%'
    GROUP BY
        category_name
    ORDER BY
        total_rental_hours DESC
    LIMIT 1
)