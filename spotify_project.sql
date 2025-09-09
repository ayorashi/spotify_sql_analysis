
-- Advance SQL Project -- Spotify Datasets

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


-- EDA 
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;
SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;
SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;
SELECT * FROM spotify
Where duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;
SELECT * FROM spotify
Where duration_min = 0;

SELECT DISTINCT channel FROM spotify;
SELECT DISTINCT most_played_on FROM spotify;

/*
-- ----------------------------------
-- DATA ANALYSIS - EASY CATEGORY
-- -----------------------------------
Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.
*/
-- Q1. Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify
WHERE stream > 1000000000;

-- Q2. List all albums along with their respective artists.
SELECT
    DISTINCT album, artist
FROM spotify
ORDER BY 1;


SELECT
    DISTINCT album
FROM spotify
ORDER BY 1;

-- Q3. Get the total number of comments for tracks where licensed = TRUE.
SELECT DISTINCT licensed FROM spotify;

SELECT 
   SUM(comments) as total_comments
   FROM spotify
WHERE licensed = 'true';


-- 	Q4. Find all tracks that belong to the album type single.

SELECT * FROM spotify
WHERE album_type ILIKE 'single';

-- Q5. Count the total number of tracks by each artist.
SELECT 
      artist, ---1
	  count (*) as total_no_songs ---2
	  FROM spotify
GROUP BY artist
ORDER BY 2 

/*
-- Medium level questions
-----------------------------------
1. Calculate the average danceability of tracks in each album.
2. Find the top 5 tracks with the highest energy values.
3. List all tracks along with their views and likes where official_video = TRUE.
4. For album, calculate the total views of all associated tracks.
5. Retrieve the track names that have been streamed on Spotify more than YouTube.
-----------------------------------------
*/

--Q6. 1. Calculate the average danceability of tracks in each album.
SELECT
      ALBUM,
	  AVG(dancebility) AS avg_dancebility
FROM spotify
GROUP BY 1
ORDER BY 2 DESC

--2. Find the top 5 tracks with the highest energy values.

SELECT 
      track,
	  Max(energy)
FROM spotify
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5

-- 3. List all tracks along with their views and likes where official_video = TRUE.	  
SELECT 
      track,
	  MAX(energy)
FROM spotify
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5

-- 4. For album, calculate the total views of all associated tracks.
SELECT 
      album,
	  track,
	  SUM(views)
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC

-- 5. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(
  SELECT 
      track,
      COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) AS streamed_on_youtube,
      COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) AS streamed_on_spotify
  FROM spotify 
  GROUP BY track
) AS t1
WHERE
      streamed_on_spotify > streamed_on_youtube
      AND
      streamed_on_youtube <> 0;
	  
	  
-------Advanced Problems
/*
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/


-- 1) Top 3 most-viewed tracks for each artist (window function)
SELECT *
FROM (
  SELECT
    track_id,
    track_name,
    artist_name,
    views,
    ROW_NUMBER() OVER (PARTITION BY artist_name ORDER BY views DESC) AS rn
  FROM tracks
) t
WHERE rn <= 3
ORDER BY artist_name, rn;


-- 2) Tracks where liveness is above the overall average
SELECT
  track_id,
  track_name,
  artist_name,
  liveness
FROM tracks
WHERE liveness > (SELECT AVG(liveness) FROM tracks);



-- 3) WITH clause: difference between highest and lowest energy per artist
WITH energy_span AS (
  SELECT
    artist_name,
    MAX(energy) AS max_energy,
    MIN(energy) AS min_energy,
    MAX(energy) - MIN(energy) AS energy_range
  FROM tracks
  GROUP BY artist_name
)
SELECT *
FROM energy_span
ORDER BY energy_range DESC;



-- 4) Tracks where energy-to-liveness ratio > 1.2 (safe against divide-by-zero)
SELECT
  track_id,
  track_name,
  artist_name,
  energy,
  liveness,
  energy / NULLIF(liveness, 0) AS energy_to_liveness
FROM tracks
WHERE energy / NULLIF(liveness, 0) > 1.2;


-- 5) Cumulative sum of likes ordered by views (window function, global)
SELECT
  track_id,
  track_name,
  artist_name,
  views,
  likes,
  SUM(likes) OVER (ORDER BY views DESC, track_id) AS cumulative_likes
FROM tracks
ORDER BY views DESC, track_id;

-- If you prefer cumulative per artist instead of global, use:
-- SUM(likes) OVER (PARTITION BY artist_name ORDER BY views DESC, track_id) AS cumulative_likes_by_artist
 




