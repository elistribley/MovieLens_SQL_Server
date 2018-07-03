USE movies
GO

DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS	
GO
-- -- -- average rate of every genre
SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT MType.genres, AVG(Ratings.Rate) avg_rate
FROM dbo.MovieType MType, dbo.Ratings Ratings
WHERE MType.MovieId = Ratings.MovieId
GROUP BY MType.genres

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS	
GO

-- -- -- The query2 without any index run for 27093ms.


-- -- -- Since MovieId is used in the query requirement,we consider create index on it.

CREATE NONCLUSTERED
INDEX MovieID_INDEX
ON dbo.Ratings(MovieId)

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT MType.genres, AVG(Ratings.Rate) avg_rate
FROM dbo.MovieType MType, dbo.Ratings Ratings
WHERE MType.MovieId = Ratings.MovieId
GROUP BY MType.genres

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
DROP INDEX dbo.Ratings.MovieID_INDEX
DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS
GO

-- -- -- The query2 with index on MovieId run for 27531ms

-- -- -- Considered that we need the correspoding Rate other than the MovieId, we try to create cover index
CREATE NONCLUSTERED
INDEX MovieID_INCLUDE_INDEX
ON dbo.Ratings(MovieId)
INCLUDE (Rate)

SET STATISTICS TIME ON
SET STATISTICS IO ON

SELECT MType.genres, AVG(Ratings.Rate) avg_rate
FROM dbo.MovieType MType, dbo.Ratings Ratings
WHERE MType.MovieId = Ratings.MovieId
GROUP BY MType.genres

SET STATISTICS TIME OFF
SET STATISTICS IO OFF
DROP INDEX dbo.Ratings.MovieID_INCLUDE_INDEX
DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS
GO

-- -- -- The query2 with cover index run for 20734ms


 




