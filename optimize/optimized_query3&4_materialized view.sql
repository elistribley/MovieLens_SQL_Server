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

USE movies
GO

DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS	
GO

IF EXISTS(SELECT 1 FROM sys.views WHERE name='PopMovie_VIEW') 
DROP VIEW PoPMovie_VIEW 
GO
IF OBJECT_ID('dbo.PopularMovie', 'U') IS NOT NULL
DROP Table dbo.PopularMovie

SET STATISTICS TIME ON
SET STATISTICS IO ON;

WITH FlagUser(UserId, MovieId) AS
(SELECT dbo.Tags.UserId, dbo.Tags.MovieId FROM dbo.Tags
UNION 
(SELECT dbo.Ratings.UserId, dbo.Ratings.MovieId FROM dbo.Ratings))

SELECT Msg.MovieId INTO PopularMovie
FROM dbo.MovieMsg Msg, FlagUser
WHERE Msg.MovieId = FlagUser.MovieId 
GROUP BY Msg.MovieId  HAVING COUNT(FlagUSer.UserId) > 10000
GO

CREATE VIEW PopMovie_VIEW
WITH SCHEMABINDING
AS
	(SELECT MovieId
	FROM dbo.PopularMovie)
GO

CREATE UNIQUE CLUSTERED 
INDEX MovieID_INDEX ON PopMovie_VIEW(MovieId)
GO
SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO

-- -- -- The Time for creating materialization view is  30093ms

SET STATISTICS TIME ON
SET STATISTICS IO ON
SELECT Movie.MovieId,Movie.title,TOP10.avg_rate
FROM Movie,
	(SELECT TOP 10 Martix.MovieId, AVG(Martix.Rate) avg_rate
	FROM dbo.UserMovieMatrix_id Martix, PopMovie_VIEW
	WHERE Martix.MovieId = PopMovie_VIEW.MovieId
	GROUP BY Martix.MovieId
	ORDER BY avg_rate DESC)TOP10
WHERE Movie.MovieId=TOP10.MovieId

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO
-- query 3 £º Total execution time: 30766ms

DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS	
GO

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT Ranked.genres,Ranked.MovieId,Movie.title,Ranked.avg_rate,Ranked.rowNum
FROM Movie,
    (SELECT MType.genres, MovieAvgRate.MovieId, avg_rate, 
        ROW_NUMBER() over
        (partition by MType.genres order by avg_rate desc) as rowNum
    FROM 
        dbo.MovieType MType,
        (SELECT Martix.MovieId MovieId, AVG(Martix.Rate) avg_rate
        FROM dbo.UserMovieMatrix_id Martix, PopMovie_VIEW
        WHERE Martix.MovieId = PopMovie_VIEW.MovieId
        GROUP BY Martix.MovieId) MovieAvgRate
    WHERE MType.MovieId = MovieAvgRate.MovieId) Ranked
WHERE Ranked.rowNum <= 10 and Ranked.MovieId=Movie.MovieId

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
GO

-- query 4: 	Total execution time: 27687ms
DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS	
GO



