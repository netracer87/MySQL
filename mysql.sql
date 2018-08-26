Use sakila;

-- 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name
FROM actor
;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT upper(concat(first_name, ' ', last_name))
FROM actor
;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT a.actor_id, a.first_name, a.last_name
FROM actor a 
WHERE a.first_name = 'Joe'
;

-- 2b. Find all actors whose last name contain the letters GEN

SELECT a.actor_id, a.first_name, a.last_name
FROM actor a 	
WHERE a.last_name like '%GEN%'
;

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order

SELECT
	a.first_name, a.last_name
FROM
	actor a 
WHERE
	a.last_name like '%LI%'
ORDER BY 
	2, 1
;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China

SELECT	
	country_id, country
FROM
	country
WHERE
	country IN ('Afghanistan', 'Bangladesh', 'China')
;

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD COLUMN description BLOB
;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column

ALTER TABLE actor
DROP COLUMN description
;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT
	last_name, count(*)
FROM
	actor 
GROUP BY 
	last_name
;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT
	last_name, count(*) AS count_last_name
FROM
	actor
GROUP BY
	last_name
HAVING
	count_last_name > 1
;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE
	actor 
SET 
	first_name = 'HARPO'
WHERE
	last_name = 'WILLIAMS' 
	AND 
	first_name = 'GROUCHO' 
; 

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE
	actor 
SET 
	first_name = 'GROUCHO'
WHERE
	first_name = 'HARPO' 
; 

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE address
;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address

SELECT
	s.first_name, s.last_name, a.address
FROM
	staff s
	JOIN address a USING(address_id)
;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment

SELECT
	a.staff_id, SUM(p.amount), p.payment_date
FROM
	staff a 
	JOIN payment p USING(staff_id)
WHERE
	left(p.payment_date, 7) = '2005-08'
GROUP BY
	1
;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join

SELECT
	f.title, count(fa.actor_id)
FROM
	film_actor fa 
	JOIN
	film f USING(film_id)
GROUP BY
	1
;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT
	f.title, count(i.inventory_id)
FROM
	inventory i 
	JOIN
	film f USING(film_id)
WHERE
	f.title = 'Hunchback Impossible'
;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT
	c.customer_id, c.first_name, c.last_name, SUM(p.amount)
FROM
	payment p 
	JOIN
	customer c USING(customer_id)
GROUP BY
	1
ORDER BY
	3 
;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.


SELECT f.title
FROM 
	film f 
WHERE
	(f.title LIKE 'K%'
	OR
	f.title LIKE 'Q%')
	AND
	f.language_id IN  
		(SELECT 
			language_id
		FROM
			language 
		WHERE 
			name = 'English'
		)
;


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- film: film_id, film_title
-- actor: actor_id, first_name, last_name
-- film_actor: actor_id, film_id

SELECT 
	a.actor_id, a.first_name, a.last_name
FROM
	actor a  
WHERE
	actor_id IN 
		(SELECT
			actor_id
		from film_actor 
		WHERE 
			film_id IN 
				(SELECT
					film_id
				FROM film
				WHERE 
					title = 'Alone Trip'
					)
			)
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- customer: customer_id, address_id
-- address: address_id, city_id,
-- city: city_id, country_id
-- country: country_id, country

SELECT
	c.first_name, c.last_name, c.email, co.country 
FROM
	customer c 
	JOIN
	address a USING(address_id)
	JOIN
	city USING (city_id)
	JOIN
	country co USING(country_id)
WHERE
	co.country = 'Canada'
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT
	f.title, c.name
FROM
	film f
	JOIN
	film_category fc USING(film_id)
	JOIN
	category c USING(category_id)
WHERE
	c.name = 'family'
;

-- 7e. Display the most frequently rented movies in descending order.
-- rental: rental_id, inventory_id
-- inventory: inventory_id, film_id
-- film: film_id

SELECT
	f.title, COUNT(r.rental_id)
FROM
	film f 
	JOIN
	inventory i USING(film_id)
	JOIN
	rental r USING(inventory_id)
GROUP BY
	1
ORDER BY
	2 DESC 
;

-- 7f. Write a query to display how much business, in dollars, each store brought in
-- payment: amount, rental_id, customer_id
-- store: store_id, address_id
-- rental: rental_id, inventory_id, customer_id
-- inventory: store_id, film_id, inventory_id

SELECT
	s.store_id, SUM(p.amount)
FROM
	store s 
	JOIN
	inventory USING(store_id)
	JOIN
	rental USING(inventory_id)
	JOIN
	payment p USING(rental_id)
GROUP BY
	1
ORDER BY
	2 DESC
;

-- 7g. Write a query to display for each store its store ID, city, and country
-- store: store_id, address_id
-- city: city, city_id, country_id
-- country: country, country_id
-- address: address_id, city_id

SELECT
	s.store_id, c.city, co.country 
FROM
	store s 
	JOIN
	address USING(address_id)
	JOIN
	city c USING(city_id)
	JOIN
	country co USING(country_id)
;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

-- payment: amount, payment_id, rental_id
-- film_category: category_id, film_id
-- category: category_id, name
-- rental: rental_id, inventory_id
-- inventory: inventory_id, film_id	

SELECT
	c.name, SUM(p.amount)
FROM
	category c 
	JOIN
	film_category USING(category_id)
	JOIN
	inventory USING(film_id)
	JOIN
	rental USING(inventory_id)
	JOIN
	payment p USING(rental_id)
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT 5
;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_5 AS 
SELECT
	c.name, SUM(p.amount)
FROM
	category c 
	JOIN
	film_category USING(category_id)
	JOIN
	inventory USING(film_id)
	JOIN
	rental USING(inventory_id)
	JOIN
	payment p USING(rental_id)
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT 5
;

-- 8b. How would you display the view that you created in 8a?

CREATE VIEW top_5 AS 
SELECT
	c.name as 'Top 5 Genres', SUM(p.amount) as 'Total Revenue'
FROM
	category c 
	JOIN
	film_category USING(category_id)
	JOIN
	inventory USING(film_id)
	JOIN
	rental USING(inventory_id)
	JOIN
	payment p USING(rental_id)
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT 5
;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_5;

