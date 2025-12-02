-- Query 1
SELECT 
    c.name, 
    COUNT(fc.film_id)
FROM film_category fc
JOIN category c USING (category_id)
GROUP BY c.name
ORDER BY COUNT(fc.film_id) DESC;

-- Query 2
SELECT 
    CONCAT(a.first_name, ' ', a.last_name) as full_name,
    COUNT(fa.actor_id)
FROM rental r 
JOIN inventory i USING(inventory_id)
JOIN film_actor fa USING(film_id)
JOIN actor a USING(actor_id)
GROUP BY full_name
ORDER BY COUNT(fa.actor_id) DESC
LIMIT 10;

-- Query 3
SELECT 
    c.name,
    SUM(p.amount) AS revenue
FROM rental r
JOIN inventory i USING(inventory_id)
JOIN film_category fc USING(film_id)
JOIN payment p USING(rental_id)
JOIN category c USING(category_id)
GROUP BY c.name
ORDER BY revenue DESC
LIMIT 1

-- Query 4
SELECT f.title, inventory_id
FROM inventory i
RIGHT JOIN film f USING (film_id)
WHERE inventory_id IS NULL;

-- Query 5
WITH actor_count AS (
	SELECT 
		CONCAT(a.first_name,' ',a.last_name) AS full_name,
		COUNT(*) AS films_amount,
		RANK() OVER (ORDER BY COUNT(film_id) DESC) AS rank_position
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
WHERE rank_position <= 3;

-- Query 6
SELECT 
    c.city,
    COUNT(CASE WHEN cus.active = 1 THEN 1 END) AS active_customers,
    COUNT(CASE WHEN cus.active = 0 THEN 1 END) AS inactive_customers
FROM customer cus
JOIN address a USING(address_id)
JOIN city c USING(city_id)
GROUP BY c.city
ORDER BY inactive_customers DESC

-- Query 7 
WITH RentalDetails AS (
    SELECT
        c.name AS category_name,
        ci.city,
        EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600 AS rental_hours
    FROM
        category c
    JOIN
        film_category fc USING(category_id)
    JOIN
        film f fc USING(film_id)
    JOIN
        inventory i USING(film_id)
    JOIN
        rental r USING(inventory_id)
    JOIN
        customer cu USING(customer_id)
    JOIN
        address a USING(address_id)
    JOIN
        city ci USING(city_id)
    WHERE
        r.return_date IS NOT NULL
),

CategoryHours AS (
    SELECT
        city_group,
        category_name,
        SUM(rental_hours) AS total_rental_hours
    FROM
        (
            SELECT
                'cities starting with a' AS city_group,
                category_name,
                rental_hours
            FROM
                RentalDetails
            WHERE
                city ILIKE 'a%'

            UNION ALL

            SELECT
                'cities with dash' AS city_group,
                category_name,
                rental_hours
            FROM
                RentalDetails
            WHERE
                city LIKE '%-%'
        ) AS FilteredRentals
    GROUP BY
        city_group,
        category_name
),

RankedHours AS (
    SELECT
        city_group,
        category_name,
        total_rental_hours,
        DENSE_RANK() OVER (PARTITION BY city_group ORDER BY total_rental_hours DESC) as rnk
    FROM
        CategoryHours
)

SELECT
    city_group,
    category_name,
    total_rental_hours
FROM
    RankedHours
WHERE
    rnk = 1
ORDER BY
    city_group,
    total_rental_hours DESC;