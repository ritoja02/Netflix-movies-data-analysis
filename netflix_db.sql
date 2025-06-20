CREATE TABLE netflix
(
show_id      VARCHAR(5),
    show_type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    show_cast        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM netflix;

--Count the Number of Movies vs TV Shows
SELECT show_type,
		COUNT(*) AS count_type
FROM netflix
GROUP BY show_type;

--Find the Most Common Rating for Movies and TV Shows
SELECT show_type, rating, count_rating
FROM (
    SELECT show_type, rating, COUNT(*) AS count_rating,
           RANK() OVER (PARTITION BY show_type 
		   				ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix
    GROUP BY show_type, rating
) ranked
WHERE rnk = 1;

--List All Movies Released in a Specific Year 
WITH movie_list AS (SELECT title, release_year 
					FROM netflix 
					WHERE show_type LIKE 'Movie')
SELECT COUNT(title), release_year
FROM movie_list
GROUP BY release_year
ORDER BY COUNT(title) DESC

--Find the Top 5 Countries with the Most Content on Netflix
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

--Identify the Longest Movie
SELECT title, duration FROM (SELECT title, duration 
FROM netflix
WHERE show_type = 'Movie')
WHERE duration IS NOT null
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;

--Find Content Added in the Last 5 Years
SELECT * FROM netflix 
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT title FROM netflix
WHERE director = 'Rajiv Chilaka';

--List All TV Shows with More Than 5 Seasons
SELECT title, duration FROM (SELECT * FROM netflix 
WHERE show_type = 'TV Show') as TV_shows
WHERE SPLIT_PART(duration, ' ', 1)::INT > 5;

--Count the Number of Content Items in Each Genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
		COUNT(*)
FROM netflix
GROUP BY genre

--Find each year and the average numbers of content release in India on netflix.
SELECT release_year, ROUND(AVG(content_count),2) FROM (SELECT release_year, 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS country, 
	COUNT(*) AS content_count
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year)
GROUP BY country, release_year
ORDER BY AVG(content_count) DESC;

--List All Movies that are Documentaries
SELECT COUNT(title) FROM (SELECT title, UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
FROM netflix
WHERE show_type = 'Movie')
WHERE genre LIKE '%Documentaries%',

--Find All Content Without a Director
SELECT * FROM netflix 
WHERE director IS NULL

--Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT title FROM
	(SELECT title,
		UNNEST(STRING_TO_ARRAY(show_cast, ',')) AS casts,
		release_year
FROM netflix 
WHERE release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10)
WHERE casts LIKE '%Salman Khan%';

--Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT casts, movie_count FROM (SELECT UNNEST(STRING_TO_ARRAY(show_cast, ',')) AS casts,
		UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
		COUNT(*) AS movie_count
FROM netflix
WHERE show_type = 'Movie'
GROUP BY casts, country
HAVING country = 'India')
ORDER BY movie_count DESC
LIMIT 10;

--Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT category, COUNT(*) FROM (
	SELECT title,
	CASE 
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Violent'
		ELSE 'Non-violent'
	END AS category
	FROM netflix)
GROUP BY category;

--