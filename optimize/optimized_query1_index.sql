USE movies
GO


DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS
GO

SET STATISTICS TIME ON
SET STATISTICS IO ON
-- -- -- the number of movies of every genre
SELECT dbo.MovieType.genres, count(*) movie_num FROM dbo.MovieType
GROUP BY dbo.MovieType.genres	

SET STATISTICS TIME OFF
SET STATISTICS IO OFF

DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS
GO

-- -- -- The query1 without index on genres run for 203ms.


-- -- -- Since genres is often used for group,it's reasonable to create index on genres.
CREATE NONCLUSTERED
INDEX GENRES_NONCLU_INDEX
ON dbo.MovieType(genres)


SET STATISTICS TIME ON
SET STATISTICS IO ON
-- -- -- the number of movies of every genre
SELECT dbo.MovieType.genres, count(*) movie_num FROM dbo.MovieType
GROUP BY dbo.MovieType.genres	

SET STATISTICS TIME OFF
SET STATISTICS IO OFF

-- -- -- The query1 with index on genres run for 125ms.
DROP INDEX dbo.MovieType.GENRES_NONCLU_INDEX
DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS
GO

CREATE NONCLUSTERED COLUMNSTORE
INDEX GENRES_NONCLU_COL_INDEX
ON dbo.MovieType(genres)


SET STATISTICS TIME ON
SET STATISTICS IO ON
-- -- -- the number of movies of every genre
SELECT dbo.MovieType.genres, count(*) movie_num FROM dbo.MovieType
GROUP BY dbo.MovieType.genres	

SET STATISTICS TIME OFF
SET STATISTICS IO OFF

-- -- -- The query1 with index on genres run for 125ms.
DROP INDEX dbo.MovieType.GENRES_NONCLU_COL_INDEX
DBCC FREEPROCCACHE
DBCC FREESESSIONCACHE
DBCC FREESYSTEMCACHE('ALL')
DBCC DROPCLEANBUFFERS
GO
