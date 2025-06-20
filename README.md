# Netflix-movies-data-analysis

## 📁 Project Overview

This project explores and analyzes a Netflix dataset using **SQL** to uncover insights about content trends, types, ratings, and more. The goal is to demonstrate practical SQL skills in data importing, querying, and deriving business-relevant insights from structured data. PostgreSQL was used to answer 15 questions mentioned below.  

---

## 🎯 Objectives

- Rank movies and TV shows by rating.
- Identify countries having the most content uploaded on Netflix.
- Count the number of movies released per year.
- Group movies based on the Genre.
- Find the actors having starred in the most number of movies.
- Categorize content based on certain words in the description.
- Find the average number of content released in India.



## 🛠️ Tools Used

- PostgreSQL
- PgAdmin
- CSV dataset imported into PostgreSQL

---

## 🧾 Dataset

Dataset from Kaggle.com : [Movies dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

The dataset used for this project contains information on Netflix movies or TV shows and includes the following key columns:

- `show_id`
- `type` (Movie/TV Show)
- `title`
- `director`
- `show_cast`
- `country`
- `date_added`
- `release_year`
- `rating`
- `duration`
- `listed_in`
- `description`

---

## Questions 

1. Count the Number of Movies vs TV Shows
2. Find the Most Common Rating for Movies and TV Shows
3. List All Movies Released in a Specific Year
4. Find the Top 5 Countries with the Most Content on Netflix
5. Identify the Longest Movie
6. Find Content Added in the Last 5 Years
7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
8. List All TV Shows with More Than 5 Seasons
9. Count the Number of Content Items in Each Genre
10. Find each year and the average numbers of content release in India on netflix.
11. List All Movies that are Documentaries
12. Find All Content Without a Director
13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords


## Solutions

1. Count the Number of Movies vs TV Shows
```sql
SELECT show_type,
		COUNT(*) AS count_type
FROM netflix
GROUP BY show_type;
```

2. Find the Most Common Rating for Movies and TV Shows
```sql
SELECT show_type, rating, count_rating
FROM (
    SELECT show_type, rating, COUNT(*) AS count_rating,
           RANK() OVER (PARTITION BY show_type 
		   				ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix
    GROUP BY show_type, rating
) ranked
WHERE rnk = 1;
```

3. List All Movies Released in a Specific Year
```sql
WITH movie_list AS (SELECT title, release_year 
					FROM netflix 
					WHERE show_type LIKE 'Movie')
SELECT COUNT(title), release_year
FROM movie_list
GROUP BY release_year
ORDER BY COUNT(title) DESC
```

4. Find the Top 5 Countries with the Most Content on Netflix
```sql
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
```

5. Identify the Longest Movie
```sql
SELECT title, duration FROM (SELECT title, duration 
FROM netflix
WHERE show_type = 'Movie')
WHERE duration IS NOT null
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;
```

6. Find Content Added in the Last 5 Years
```sql
SELECT * FROM netflix 
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
```sql
SELECT title FROM netflix
WHERE director = 'Rajiv Chilaka';
```

8. List All TV Shows with More Than 5 Seasons
```sql
SELECT title, duration FROM (SELECT * FROM netflix 
WHERE show_type = 'TV Show') as TV_shows
WHERE SPLIT_PART(duration, ' ', 1)::INT > 5;
```

9. Count the Number of Content Items in Each Genre
```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
		COUNT(*)
FROM netflix
GROUP BY genre
```

10. Find each year and the average numbers of content release in India on netflix.
```sql
SELECT release_year, ROUND(AVG(content_count),2) FROM (SELECT release_year, 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS country, 
	COUNT(*) AS content_count
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year)
GROUP BY country, release_year
ORDER BY AVG(content_count) DESC;
```

11. List All Movies that are Documentaries
```sql
SELECT COUNT(title) FROM (SELECT title, UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
FROM netflix
WHERE show_type = 'Movie')
WHERE genre LIKE '%Documentaries%';
```

12. Find All Content Without a Director
```sql
SELECT * FROM netflix 
WHERE director IS NULL
```

13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
```sql
SELECT title FROM
	(SELECT title,
		UNNEST(STRING_TO_ARRAY(show_cast, ',')) AS casts,
		release_year
FROM netflix 
WHERE release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10)
WHERE casts LIKE '%Salman Khan%';
```

14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
```sql
SELECT casts, movie_count FROM (SELECT UNNEST(STRING_TO_ARRAY(show_cast, ',')) AS casts,
		UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
		COUNT(*) AS movie_count
FROM netflix
WHERE show_type = 'Movie'
GROUP BY casts, country
HAVING country = 'India')
ORDER BY movie_count DESC
LIMIT 10;
```

15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
```sql
SELECT category, COUNT(*) FROM (
	SELECT title,
	CASE 
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Violent'
		ELSE 'Non-violent'
	END AS category
	FROM netflix)
GROUP BY category;
```


## 📌 Key Insights

- There are more number of movies on Netflix than there are TV shows.
- The maximum number of movies got released in the years 2017 and 2018.
-  United States, India, United Kingdom and Canada have contributed to the most content on Netflix till date.
-  The lengthiest movie is of 312 minutes.
-  99 shows have over 5 seasons.
-  "Drama" is the most common genre.
-  Netflix has 869 Documentaries.  
