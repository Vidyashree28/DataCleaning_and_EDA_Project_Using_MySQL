--create database
CREATE DATABASE netflix_data;

--create table
CREATE TABLE netflix_d(
	show_id VARCHAR(10),
	type VARCHAR(20),
	title VARCHAR(1000),
	director VARCHAR(300),
	"cast" VARCHAR(2000),
	country VARCHAR(400),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(30),
	duration VARCHAR(30),
	listed_in VARCHAR(2000),
	description VARCHAR(2000)
);

--View dataset
select * from netflix_d;

--Check for duplicates in show_id
SELECT show_id, COUNT(*)                                                                                                                                                                            
FROM netflix_d 
GROUP BY show_id                                                                                                                                                                                            
ORDER BY show_id DESC;

--Check null values across columns
SELECT COUNT(*) FILTER (WHERE show_id IS NULL) AS showid_nulls,
       COUNT(*) FILTER (WHERE type IS NULL) AS type_nulls,
       COUNT(*) FILTER (WHERE title IS NULL) AS title_nulls,
       COUNT(*) FILTER (WHERE director IS NULL) AS director_nulls,
       COUNT(*) FILTER (WHERE "cast" IS NULL) AS cast_nulls,
       COUNT(*) FILTER (WHERE country IS NULL) AS country_nulls,
       COUNT(*) FILTER (WHERE date_added IS NULL) AS date_addes_nulls,
       COUNT(*) FILTER (WHERE release_year IS NULL) AS release_year_nulls,
       COUNT(*) FILTER (WHERE rating IS NULL) AS rating_nulls,
       COUNT(*) FILTER (WHERE duration IS NULL) AS duration_nulls,
       COUNT(*) FILTER (WHERE listed_in IS NULL) AS listed_in_nulls,
       COUNT(*) FILTER (WHERE description IS NULL) AS description_nulls
FROM netflix_d;

--Check if some directors are likely to work with particular cast
WITH cte AS
(
SELECT title, CONCAT(director, '---', "cast") AS director_cast 
FROM netflix_d
)

SELECT director_cast, COUNT(*) AS count
FROM cte
GROUP BY director_cast
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

--Repeat this step to populate the rest of the director nulls
UPDATE netflix 
SET director = 'Alastair Fothergill'
WHERE movie_cast = 'David Attenborough'
AND director IS NULL ;

--Populate the rest of the NULL in director as "Not Given"
UPDATE netflix 
SET director = 'Not Given'
WHERE director IS NULL;

--Populate the country using the director column
SELECT COALESCE(nt.country,nt2.country) 
FROM netflix_d  AS nt
JOIN netflix_d AS nt2 
ON nt.director = nt2.director 
AND nt.show_id <> nt2.show_id
WHERE nt.country IS NULL;
UPDATE netflix_d
SET country = nt2.country
FROM netflix_d AS nt2
WHERE netflix_d.director = nt2.director and netflix_d.show_id <> nt2.show_id 
AND netflix_d.country IS NULL;

--Confirm if there are still directors linked to country that refuse to update
SELECT director, country, date_added
FROM netflix_d
WHERE country IS NULL;

--Populate the rest of the NULL in director as "Not Given"
UPDATE netflix_d 
SET country = 'Not Given'
WHERE country IS NULL;

--Show date_added nulls
SELECT show_id, date_added
FROM netflix_d
WHERE date_added IS NULL;

--DELETE nulls
DELETE FROM netflix_d
WHERE show_id 
IN ('s6796', 's6067', 's6175', 's6807', 's6902', 's7255', 's7197', 's7407', 's7848', 's8183');

--Show rating NULLS
SELECT show_id, rating
FROM netflix_d
WHERE date_added IS NULL;

--Delete the nulls, and show deleted fields
DELETE FROM netflix_d 
WHERE show_id 
IN (SELECT show_id FROM netflix_d WHERE rating IS NULL)
RETURNING *;

--Delete duration nulls
DELETE FROM netflix_d 
WHERE show_id 
IN (SELECT show_id FROM netflix_d WHERE duration IS NULL);

--Check to confirm the number of rows are the same(NO NULL)
SELECT count(*) filter (where show_id IS NOT NULL) AS showid_nulls,
       count(*) filter (where type IS NOT NULL) AS type_nulls,
       count(*) filter (where title IS NOT NULL) AS title_nulls,
       count(*) filter (where director IS NOT NULL) AS director_nulls,
       count(*) filter (where country IS NOT NULL) AS country_nulls,
       count(*) filter (where date_added IS NOT NULL) AS date_addes_nulls,
       count(*) filter (where release_year IS NOT NULL) AS release_year_nulls,
       count(*) filter (where rating IS NOT NULL) AS rating_nulls,
       count(*) filter (where duration IS NOT NULL) AS duration_nulls,
       count(*) filter (where listed_in IS NOT NULL) AS listed_in_nulls
FROM netflix_d;

--DROP not needed columns
ALTER TABLE netflix_d
DROP COLUMN "cast", 
DROP COLUMN description;

--split the country column and retain the first country by the left 
SELECT *,
       SPLIT_PART(country,',',1) AS countryy, 
           SPLIT_PART(country,',',2),
       SPLIT_PART(country,',',4),
       SPLIT_PART(country,',',5),
       SPLIT_PART(country,',',6),
       SPLIT_PART(country,',',7),
       SPLIT_PART(country,',',8),
       SPLIT_PART(country,',',9),
       SPLIT_PART(country,',',10) 

FROM netflix_d;

--update the table and create a column named country1 and Update it with the first split country.
ALTER TABLE netflix_d 
ADD country1 varchar(500);
UPDATE netflix_d 
SET country1 = SPLIT_PART(country, ',', 1);

--Delete column
ALTER TABLE netflix_d 
DROP COLUMN country;

--Rename the country1 column to country
ALTER TABLE netflix_d 
RENAME COLUMN country1 TO country;

