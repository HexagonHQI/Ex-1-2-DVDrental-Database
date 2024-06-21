-- Exercise 1: 
--1. Get a list of all the languages, from the language table.

SELECT name FROM language
INNER JOIN film ON film.language_id = language.language_id;
--2. Get a list of all films joined with their languages – select the following details : film title, description, and language name. 
--Try your query with different joins:
--Get all films, even if they don’t have languages--
SELECT title, description, name FROM film
FULL OUTER JOIN language ON film.language_id = language.language_id;
-- 3.Get all languages, even if there are no films in those languages – select the following details : film title, description, and language name.
SELECT l.name AS language_name, f.title, f.description
FROM language l
LEFT JOIN film f ON f.language_id = l.language_id;

--4. Create a new table called new_film with the following columns : id, name. Add some new films to the table:
 CREATE TABLE new_film (
	 id INTEGER PRIMARY KEY,
	 name varchar(50)
 );
 INSERT INTO new_film
 VALUES 
 	(1006, 'The Last Samurai'),
	(1007, 'Wallace and Gromit'),
	(1008, 'Mrs.Doubtfire'),
	(1009, 'A Beautiful Mind'),
	(1010, 'Cast Away');
--5. Create a new table called customer_review, which will contain film reviews that customers will make.
--Think about the DELETE constraint: if a film is deleted, it’s review should be automatically deleted.
-- It should have the following columns:
-- review_id – a primary key, non null, auto-increment.
-- film_id – references the new_film table. The film that is being reviewed.
-- language_id – references the language table. What language the review is in.
-- title – the title of the review.
-- score – the rating of the review (1-10).
-- review_text – the text of the review. No limit on the length.
-- last_update – when the review was last updated.
CREATE TABLE customer_review (
	review_id SERIAL NOT NULL PRIMARY KEY,
	film_id INTEGER,
	language_id INTEGER,
	title varchar(50),
	score INTEGER CHECK(score >= 1 AND score <= 10),
	review_text varchar,
	last_update timestamp,
	FOREIGN KEY (film_id) REFERENCES new_film (id) ON DELETE CASCADE,
	FOREIGN KEY (language_id) REFERENCES language (language_id)
);
SELECT * FROM customer_review;
--6. Add 2 movie reviews. Make sure you link them to valid objects in the other tables:
INSERT INTO customer_review (review_id, film_id, language_id, title, score, review_text, last_update)
VALUES 
(1, (SELECT id FROM new_film WHERE new_film.name = 'The Last Samurai'), (SELECT language_id FROM language WHERE language_id = 4), 'The Last Samurai', 8, 'A dazzling, exhilarating, refreshingly character-driven and thoroughly captivating experience that must be seen on the big screen. It`s unlike any film you`ve seen before.', '2006-02-17'),
(2, (SELECT id FROM new_film WHERE new_film.name = 'Cast Away'), (SELECT language_id FROM language WHERE language_id = 2), 'Cast Away', 9, 'Remains one of the more vividly transporting films I`ve come into contact with. It`s heartbreaking, darkly comedic, bravely observational, and ultimately, pure emotional poetry.', '2006-02-20');
--7. Delete a film that has a review from the new_film table, what happens to the customer_review table?
DELETE FROM new_film WHERE id = 1010;
-- Record was also deleted in customer_review


-- Exercise 2:
--1. Use UPDATE to change the language of some films. Make sure that you use valid languages:
UPDATE film
SET language_id = 2
WHERE length >= 180;
--2. Which foreign keys (references) are defined for the customer table? 
--How does this affect the way in which we INSERT into the customer table?
----The table customer has a constraint of a foreign key which references the address_id in the address table.
----In order to insert, you need to select the associated address_id in the address table when you list the values to insert.
--3. We created a new table called customer_review. Drop this table. 
--Is this an easy step, or does it need extra checking?
----Since the child table (customer_review) was created with a foreign key with the constraint ON DELETE CASCADE, 
----deleting the customer_review table will not affect other tables since it is not referenced by any of them
DROP TABLE customer_review;
--4. Find out how many rentals are still outstanding (ie. have not been returned to the store yet):
SELECT COUNT(*) AS total_outstanding FROM rental
WHERE rental_date IS NOT NULL AND return_date IS NULL;
--5. Find the 30 most expensive movies which are outstanding (ie. have not been returned to the store yet):
SELECT * FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
WHERE rental_date IS NOT NULL AND return_date IS NULL
ORDER BY rental_rate DESC LIMIT(30);
--6. Your friend is at the store, and decides to rent a movie. He knows he wants to see 4 movies, but he can’t remember their names. 
--Can you help him find which movies he wants to rent?
--The 1st film : The film is about a sumo wrestler, and one of the actors is Penelope Monroe.
SELECT * FROM film
RIGHT JOIN film_actor ON film_actor.film_id = film.film_id
INNER JOIN actor ON actor.actor_id = film_actor.actor_id
WHERE description iLIKE '%sumo%' AND actor.first_name = 'Penelope' AND actor.last_name = 'Monroe';
--2. The 2nd film : A short documentary (less than 1 hour long), rated “R”.
SELECT * FROM film
RIGHT JOIN film_category ON film.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
WHERE rating = 'R' AND length < 60 AND category.name iLIKE 'documentary';
--3. The 3rd film : A film that his friend Matthew Mahan rented. 
--He paid over $4.00 for the rental, and he returned it between the 28th of July and the 1st of August, 2005.
SELECT title, description, first_name || ' ' || last_name AS full_name, rental_rate, return_date FROM film 
LEFT JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
RIGHT JOIN customer ON rental.customer_id = customer.customer_id
WHERE rental_rate > 4 AND return_date BETWEEN '2005-07-28' AND '2005-08-01' 
AND first_name = 'Matthew' AND last_name = 'Mahan';
--4. The 4th film : His friend Matthew Mahan watched this film, as well. 
--It had the word “boat” in the title or description, and it looked like it was a very expensive DVD to replace.
SELECT title, description, first_name || ' ' || last_name AS full_name, replacement_cost, return_date, amount FROM film 
INNER JOIN inventory ON film.film_id = inventory.film_id 
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN customer ON rental.customer_id = customer.customer_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
WHERE first_name = 'Matthew' AND last_name = 'Mahan' AND description iLIKE '%boat%' OR title iLIKE '%boat%'
ORDER BY replacement_cost DESC LIMIT (1);
