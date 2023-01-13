USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

/*******************************************************************************
	Using the UNION keyword in the below statement so that we see all the 
    records in the same output window.
*******************************************************************************/    

SELECT 'director_mapping' AS 'table_name',COUNT(0) AS number_of_records FROM director_mapping UNION
SELECT 'genre',COUNT(0) FROM genre UNION
SELECT 'movie',COUNT(0) FROM movie UNION
SELECT 'names',COUNT(0) FROM names UNION
SELECT 'ratings',COUNT(0) FROM ratings UNION
SELECT'role_mapping', COUNT(0) FROM role_mapping ;




-- Q2. Which columns in the movie table have null values?
-- Type your code below:

/*******************************************************************************
	Using the ISNULL() function on each column of the movie table which 
    would return 1 incase of null else 0 and taking the SUM of it to find 
    the total number of null values in each column.
*******************************************************************************/ 

SELECT
	'Number of Null values' AS description
	, SUM(isnull(id)) AS id
    , SUM(isnull(title)) as title
    , SUM(isnull(year)) as year
    , SUM(isnull(date_published)) as date_published
    , SUM(isnull(duration)) as duration
    , SUM(isnull(country)) as country
    , SUM(isnull(worlwide_gross_income)) as worlwide_gross_income
    , SUM(isnull(languages)) as languages
    , SUM(isnull(production_company)) as production_company
FROM movie;



-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
	year AS Year
    , count(*) as number_of_movies
FROM movie
group by year
order by year;

SELECT 
	month(date_published) AS month_num
    , count(id) as number_of_movies
FROM movie
group by month_num
order by month_num;








/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 
	Count(id) AS Movie_count
FROM   movie
WHERE  country REGEXP 'USA|India' -- Using REGEXP to check if the contains either USA or India
       AND year = 2019;




/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT
	genre
FROM genre;



/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT
	genre.genre
    , COUNT(movie.id) as num_of_movies
FROM genre
INNER JOIN movie
	ON movie.id = genre.movie_id
GROUP BY genre.genre
ORDER BY num_of_movies DESC
limit 1;





/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH one_genre -- CTE returns the movies having only one genre associate with it.
     AS (SELECT movie_id,
                Count(genre) AS n_genre
         FROM   genre
         GROUP  BY movie_id
         HAVING n_genre = 1
		)
SELECT Count(*) AS 'Number of movies with one genre' -- Count of total number of movies with only one genre associated.
FROM   one_genre;










/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT genre,
       Round(Avg(duration), 2) AS avg_duration
FROM   genre
       INNER JOIN movie
               ON genre.movie_id = movie.id
GROUP  BY genre
ORDER  BY avg_duration DESC;








/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH movies_per_genre as ( -- CTE returns the genres with rank based on number of movies
SELECT
	genre.genre
    , count(movie.id) as movie_count
    , rank() over (order by count(movie.id) desc) AS genre_rank
FROM genre
INNER JOIN movie
	ON movie.id = genre.movie_id
group by genre.genre
)
SELECT 
	*
FROM movies_per_genre
WHERE genre = 'Thriller'; -- filter 'Thriller' genre from CTE



/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:


SELECT
	CONVERT(min(avg_rating), UNSIGNED) AS min_avg_rating -- converting the float value to unsigned integer to meet the expected output
    , CONVERT(max(avg_rating), UNSIGNED) AS max_avg_rating -- converting the float value to unsigned integer to meet the expected output
    , min(total_votes) AS min_total_votes
    , max(total_votes) AS max_total_votes
    , min(median_rating) AS min_median_rating
    , max(median_rating) AS max_median_rating
FROM ratings;
	


    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

/*******************************************************************************
	The following SQL statement returns 14 records as there are ties on some 
    average ratings, and then the movies are sorted in the alphabetical order.
    as we do not want to filter out movies because of it's alphabetical order
    of names, we fave written the query in the following format.
*******************************************************************************/    

WITH topMovies_byAvgRatings AS ( -- Returns ranks of movies based on the Average ratings
SELECT
	movie.title
    , ratings.avg_rating
    , rank() over (order by avg_rating desc) AS movie_rank
FROM ratings
INNER JOIN movie
	ON ratings.movie_id = movie.id
)
SELECT 
	*
FROM topMovies_byAvgRatings
WHERE movie_rank <= 10;







/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT
	median_rating
    , COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;








/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

WITH production_company_ranks AS ( -- Returns production houses with rank based on movie counts where avg_rating > 8.
SELECT
	movie.production_company
    , count(movie.id) AS movie_count
    , dense_rank() over (order by count(movie.id) desc) AS prod_company_rank
FROM ratings
INNER JOIN movie
	ON ratings.movie_id = movie.id
WHERE ratings.avg_rating > 8
	AND movie.production_company IS NOT NULL -- handling NULL values in production_company column.
GROUP BY movie.production_company
)
SELECT 
	*
FROM production_company_ranks
WHERE prod_company_rank = 1;


-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT
	genre.genre
    , COUNT(movie.id) as movie_count
FROM ratings
INNER JOIN movie
	ON ratings.movie_id = movie.id
INNER JOIN genre
	ON genre.movie_id = movie.id
WHERE movie.country LIKE '%USA%'
AND movie.date_published BETWEEN '2017-03-01' AND '2017-03-31'
AND ratings.total_votes > 1000
GROUP BY genre.genre
ORDER BY movie_count DESC;


-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
	movie.title
    , ratings.avg_rating
    , genre.genre
FROM ratings
INNER JOIN movie
	ON ratings.movie_id = movie.id
INNER JOIN genre
	ON genre.movie_id = movie.id
WHERE ratings.avg_rating > 8
	AND movie.title like 'The%';



-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT 
	COUNT(movie.id) AS movie_count
FROM ratings
INNER JOIN movie
	ON ratings.movie_id = movie.id
WHERE movie.date_published BETWEEN '2018-04-01' AND '2019-04-01'
AND ratings.median_rating = 8;


-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

WITH movie_lang AS (
SELECT 
	movie.id
    , 'German' AS lang
FROM movie
WHERE movie.languages like '%German%'
UNION 
SELECT 
	movie.id
    , 'Italian' AS lang
FROM movie
WHERE movie.languages like '%Italian%'
)
SELECT 
	movie_lang.lang
    , SUM(ratings.total_votes) AS votes
FROM ratings
INNER JOIN movie_lang
	ON ratings.movie_id = movie_lang.id
GROUP BY movie_lang.lang;

    
-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT
	SUM(ISNULL(name)) AS name_nulls
    , SUM(ISNULL(height)) AS height_nulls
    , SUM(ISNULL(date_of_birth)) AS date_of_birth_nulls
    , SUM(ISNULL(known_for_movies)) AS known_for_movies_nulls
FROM names;






/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH top_genres AS ( -- Returns top 3 genres
	SELECT 
		genre.genre
		, COUNT(genre.movie_id) AS movie_count
	FROM ratings
	INNER JOIN genre
		ON genre.movie_id = ratings.movie_id
	WHERE ratings.avg_rating > 8
	GROUP BY genre.genre
	ORDER BY movie_count DESC
	limit 3
),
top_directors AS (
	SELECT
		names.name AS director_name
        , COUNT(director.movie_id) AS movie_count
        , RANK() OVER (ORDER BY COUNT(director.movie_id) DESC) AS dir_rank
	FROM names
    INNER JOIN director_mapping AS director
		ON director.name_id = names.id
	INNER JOIN ratings
		ON ratings.movie_id = director.movie_id
	INNER JOIN genre
		ON genre.movie_id = director.movie_id
	WHERE 
		ratings.avg_rating > 8
        AND genre.genre IN (SELECT genre FROM top_genres) -- Using a sub query here instead of inner join as we have only 3 values
	GROUP BY names.name
)
SELECT
	director_name
    , movie_count
FROM top_directors
WHERE dir_rank <=3;






/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH actor_rankings AS ( -- Returns actors with ranks with median rating >= 8
	SELECT 
		names.name AS actor_name
		, COUNT(roles.movie_id) AS movie_count
		, RANK() OVER (ORDER BY COUNT(roles.movie_id) DESC) AS actor_rank
	FROM role_mapping AS roles
	INNER JOIN names
		ON names.id = roles.name_id
	INNER JOIN ratings
		ON ratings.movie_id = roles.movie_id
	WHERE
		ratings.median_rating >= 8
		AND roles.category = 'actor'
	GROUP BY names.name
)
SELECT
	actor_name
    , movie_count
FROM actor_rankings
WHERE actor_rank <=2;



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH productionHouseRankings_byVotes AS (
	SELECT 
		movie.production_company
		, SUM(ratings.total_votes) AS vote_count
		, DENSE_RANK() OVER (ORDER BY SUM(ratings.total_votes) DESC) AS prod_comp_rank
	FROM ratings
	INNER JOIN movie
		ON movie.id = ratings.movie_id
	GROUP BY movie.production_company
)
SELECT
	production_company
    , vote_count
    , prod_comp_rank
FROM productionHouseRankings_byVotes
WHERE prod_comp_rank <= 3;


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH top_actors_India AS (
	SELECT
		names.name AS actor_name
		, SUM(ratings.total_votes) AS total_votes
		, COUNT(movie.id) AS movie_count
		, ROUND(SUM(ratings.avg_rating * ratings.total_votes)/SUM(ratings.total_votes), 2) AS actor_avg_rating
	FROM ratings
	INNER JOIN movie
		ON ratings.movie_id = movie.id
	INNER JOIN role_mapping AS roles
		ON roles.movie_id = movie.id
	INNER JOIN names
		ON names.id = roles.name_id
	WHERE 
		movie.country like '%India%'
		AND roles.category = 'actor'
	GROUP BY names.name
	HAVING movie_count >= 5
)
SELECT 
	*
    , RANK() OVER (ORDER BY actor_avg_rating DESC, total_votes DESC) AS actor_rank
FROM top_actors_India;


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH top_actresses_India AS (
	SELECT
		names.name AS actress_name
		, SUM(ratings.total_votes) AS total_votes
		, COUNT(movie.id) AS movie_count
		, ROUND(SUM(ratings.avg_rating * ratings.total_votes)/SUM(ratings.total_votes), 2) AS actress_avg_rating
        , RANK() OVER (ORDER BY SUM(ratings.avg_rating * ratings.total_votes)/SUM(ratings.total_votes) DESC, SUM(ratings.total_votes) DESC) AS actress_rank
	FROM ratings
	INNER JOIN movie
		ON ratings.movie_id = movie.id
	INNER JOIN role_mapping AS roles
		ON roles.movie_id = movie.id
	INNER JOIN names
		ON names.id = roles.name_id
	WHERE 
		movie.country like '%India%'
        AND movie.languages like '%Hindi%'
		AND roles.category = 'actress'
	GROUP BY names.name
	HAVING movie_count >= 3
)
SELECT
	*
FROM top_actresses_India
WHERE actress_rank <= 5;


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT 
	movie.title AS movie_title
    , ratings.avg_rating
    , CASE
		WHEN ratings.avg_rating > 8 THEN 'Superhit movies'
        WHEN ratings.avg_rating >= 7 THEN 'Hit movies'
        WHEN ratings.avg_rating >= 5 THEN 'One-time-watch movies'
        ELSE 'Flop movies'
	 END AS rating_category
FROM ratings
INNER JOIN movie
	ON movie.id = ratings.movie_id
INNER JOIN genre
	ON genre.movie_id = movie.id
WHERE 
	genre.genre = 'Thriller';



/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT     genre,
           Round(Avg(duration)) AS avg_duration,
           round(sum(Avg(duration)) OVER wdw_runningTotal, 1) AS running_total_duration,
           round(avg(avg(duration)) OVER wdw_movingAvg, 2) AS moving_avg_duration
FROM       genre
INNER JOIN movie
ON         genre.movie_id = movie.id
GROUP BY   genre 
WINDOW	   wdw_runningTotal AS (ORDER BY genre ROWS UNBOUNDED PRECEDING),
           wdw_movingAvg AS (ORDER BY genre ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING);






-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

/*******************************************************************************
	Top 5 movies for each year [2017-2019] based on the gross income. for
    top 3 genres. there were some records with currency in INR so had to
    convert them to USD based on as fixed rate of conversion. so that we could
    correctly compare the values.
*******************************************************************************/ 

WITH top_3_genres AS (
	SELECT 
		genre.genre
        , COUNT(movie.id) AS movie_count
	FROM genre
    INNER JOIN movie
		ON movie.id = genre.movie_id
	GROUP BY genre.genre
    ORDER BY movie_count DESC
    LIMIT 3
),
movie_standardized AS (
	SELECT
		genre.genre
        , movie.year
        , movie.title AS movie_name
        , CASE
			WHEN substring(movie.worlwide_gross_income,1,3) = 'INR' THEN CONCAT('$ ',ROUND(CONVERT(substring(movie.worlwide_gross_income,5), SIGNED) / 81.64)) -- when INR convert to USD
            ELSE movie.worlwide_gross_income
		 END AS worldwide_gross_income
		, DENSE_RANK() OVER (PARTITION BY year ORDER BY CASE
									WHEN SUBSTRING(movie.worlwide_gross_income,1,3) = 'INR' THEN ROUND(CONVERT(SUBSTRING(movie.worlwide_gross_income,5), SIGNED) / 81.64) -- convert STRING to SIGNED integer for order by purposes.
									ELSE CONVERT(SUBSTRING(movie.worlwide_gross_income,3), SIGNED)
								END DESC) AS movie_rank
	FROM movie
    INNER JOIN genre
		ON genre.movie_id = movie.id
    WHERE worlwide_gross_income IS NOT NULL
    AND genre.genre IN (SELECT genre FROM top_3_genres)
)
SELECT * FROM movie_standardized
WHERE movie_rank <= 5;


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH top_productionCompanies AS (
SELECT 
	movie.production_company
    , COUNT(DISTINCT movie.id) AS movie_count
    , DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT movie.id) DESC) AS prod_comp_rank
FROM ratings
INNER JOIN movie
	ON movie.id = ratings.movie_id
WHERE ratings.median_rating >= 8
AND POSITION(',' IN movie.languages) > 0
AND production_company IS NOT NULL
GROUP BY movie.production_company
)
SELECT 
	*
FROM top_productionCompanies
WHERE prod_comp_rank <= 2;





-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH top_3_actresses_byMovieCount AS (
	SELECT 
		names.name AS actress_name
		, SUM(ratings.total_votes) AS total_votes
		, COUNT(DISTINCT roles.movie_id) as movie_count
		, ROUND(SUM(ratings.avg_rating * ratings.total_votes) / SUM(total_votes),2) AS actress_avg_rating
		, RANK() OVER (ORDER BY COUNT(ratings.movie_id) DESC) AS actress_rank
	FROM ratings
	INNER JOIN role_mapping AS roles
		ON roles.movie_id = ratings.movie_id
	INNER JOIN names
		ON names.id = roles.name_id
	WHERE 
		ratings.avg_rating > 8
		AND roles.movie_id IN (SELECT DISTINCT movie_id FROM genre WHERE genre = 'drama')
		AND roles.category = 'actress'
	GROUP BY names.name
)
SELECT 
	*
FROM top_3_actresses_byMovieCount
WHERE actress_rank <= 3;






/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH movie_date_calculation AS (
	SELECT
		director.name_id
        , movie.duration
        , DATEDIFF(LEAD(date_published) OVER (PARTITION BY director.name_id ORDER BY date_published), movie.date_published) AS days_since_lastMovie -- Date difference between current movie and the next movie of same director in days
	FROM movie
    INNER JOIN director_mapping AS director
		ON director.movie_id = movie.id
),
avg_inter_days AS (
	SELECT 
		name_id
        , SUM(duration) AS total_duration
        , ROUND(AVG(days_since_lastMovie)) AS avg_inter_movie_days
	FROM movie_date_calculation
    GROUP BY name_id
), directors_ranking AS (
SELECT 
	director.name_id AS director_id
    , MAX(names.name) AS director_name
    , COUNT(director.movie_id) AS number_of_movies
    , avg_inter_movie_days
    , ROUND(SUM(ratings.avg_rating * ratings.total_votes) / SUM(total_votes),2) AS avg_rating
    , SUM(ratings.total_votes) AS total_votes
    , MIN(ratings.avg_rating) AS min_rating
    , MAX(ratings.avg_rating) AS max_rating
    , total_duration
    , RANK() OVER(ORDER BY COUNT(director.movie_id) DESC) AS dir_rank
FROM director_mapping AS director
INNER JOIN names
	ON names.id = director.name_id
INNER JOIN ratings
	ON ratings.movie_id = director.movie_id
INNER JOIN avg_inter_days
	ON avg_inter_days.name_id = director.name_id
GROUP BY director.name_id
)
SELECT 
	director_id
    , director_name
    , number_of_movies
    , avg_inter_movie_days
    , avg_rating
    , total_votes
    , min_rating
    , max_rating
    , total_duration
FROM directors_ranking
WHERE dir_rank <= 9;





