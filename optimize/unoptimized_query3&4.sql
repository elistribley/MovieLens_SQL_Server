USE movies
GO

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


DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS	
GO

SET STATISTICS TIME ON
SET STATISTICS IO ON;
WITH FlagUser(UserId, MovieId) AS
(SELECT dbo.Tags.UserId, dbo.Tags.MovieId FROM dbo.Tags
UNION 
(SELECT dbo.Ratings.UserId, dbo.Ratings.MovieId FROM dbo.Ratings))

-- the top 10 highest score movies must be in table UserMovieMatrix_id
SELECT Movie.MovieId,Movie.title,TOP10.avg_rate
FROM Movie,
	(SELECT TOP 10 Martix.MovieId, AVG(Martix.Rate) avg_rate
	FROM dbo.UserMovieMatrix_id Martix, 
		(SELECT Msg.MovieId
		FROM dbo.MovieMsg Msg, FlagUser
		WHERE Msg.MovieId = FlagUser.MovieId
		GROUP BY Msg.MovieId HAVING COUNT(FlagUSer.UserId) > 10000) PopularMovie
	WHERE Martix.MovieId = PopularMovie.MovieId
	GROUP BY Martix.MovieId
	ORDER BY avg_rate DESC) TOP10
WHERE Movie.MovieId=TOP10.MovieId

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO
-- query 3 £º Total execution time: 61734ms

DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS	
GO

SET STATISTICS TIME ON
SET STATISTICS IO ON;

WITH FlagUser(UserId, MovieId) AS
(SELECT dbo.Tags.UserId, dbo.Tags.MovieId FROM dbo.Tags
UNION 
(SELECT dbo.Ratings.UserId, dbo.Ratings.MovieId FROM dbo.Ratings))
--considering some type of movie, set the threshold  1,000
SELECT Ranked.genres,Ranked.MovieId,Movie.title,Ranked.avg_rate,Ranked.rowNum
FROM Movie,
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
WHERE Ranked.rowNum <= 10 and Ranked.MovieId=Movie.MovieId

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO

-- query 4: 	Total execution time: 60563ms