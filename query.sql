USE movies
GO
-- -- -- the number of movies of every genre
SELECT dbo.MovieType.genres, count(*) movie_num FROM dbo.MovieType
GROUP BY dbo.MovieType.genres	
GO

-- -- -- average rate of every genre
SELECT MType.genres, AVG(Ratings.Rate) avg_rate
FROM dbo.MovieType MType, dbo.Ratings Ratings
WHERE MType.MovieId = Ratings.MovieId
GROUP BY MType.genres	
GO

-- the two query Total execution time: 00:00:11.892


-- total number of Users 
-- SELECT count(distinct u."UserId") UserNum from dbo."UserMovieMatrix_id" u;
-- +-----------+
-- | UserNum   |
-- |-----------|
-- | 270896    |
-- +-----------+
-- so set the threshold  10,000
-- list having the top 10 highest score movies whose watch-users exceed 10,000
-- watch-users
WITH FlagUser(UserId, MovieId) AS
(SELECT dbo.Tags.UserId, dbo.Tags.MovieId FROM dbo.Tags
UNION 
(SELECT dbo.Ratings.UserId, dbo.Ratings.MovieId FROM dbo.Ratings))

-- the top 10 highest score movies must be in table UserMovieMatrix_id 
SELECT TOP 10 Martix.MovieId, AVG(Martix.Rate) avg_rate
FROM dbo.UserMovieMatrix_id Martix, 
    (SELECT Msg.MovieId
    FROM dbo.MovieMsg Msg, FlagUser
    WHERE Msg.MovieId = FlagUser.MovieId
    GROUP BY Msg.MovieId HAVING COUNT(FlagUSer.UserId) > 10000) PopularMovie
WHERE Martix.MovieId = PopularMovie.MovieId
GROUP BY Martix.MovieId
ORDER BY avg_rate DESC
GO
-- query 3 ： Total execution time: 00:00:47.918


WITH FlagUser(UserId, MovieId) AS
(SELECT dbo.Tags.UserId, dbo.Tags.MovieId FROM dbo.Tags
UNION 
(SELECT dbo.Ratings.UserId, dbo.Ratings.MovieId FROM dbo.Ratings))
--considering some type of movie, set the threshold  1,000
SELECT * FROM
    (SELECT MType.genres, MovieAvgRate.MovieId, avg_rate, 
        ROW_NUMBER() over
        (partition by MType.genres order by avg_rate desc) as rowNum
    FROM 
        dbo.MovieType MType,
        (SELECT Martix.MovieId MovieId, AVG(Martix.Rate) avg_rate
        FROM dbo.UserMovieMatrix_id Martix,
                (SELECT Msg.MovieId
                FROM 
                    dbo.MovieMsg Msg, FlagUser
                WHERE Msg.MovieId = FlagUser.MovieId
                GROUP BY Msg.MovieId
                HAVING COUNT(FlagUSer.UserId) > 10000) PopularMovie
        WHERE Martix.MovieId = PopularMovie.MovieId
        GROUP BY Martix.MovieId) MovieAvgRate
    WHERE MType.MovieId = MovieAvgRate.MovieId) Ranked
WHERE Ranked.rowNum <= 10
GO

-- query 4: 	Total execution time: 00:00:45.534