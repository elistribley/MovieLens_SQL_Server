
USE movies
SET NOCOUNT ON

-- create table Movie for importing 

IF OBJECT_ID('dbo.Movie', 'U') IS NOT NULL
DROP TABLE dbo.Movie
GO
CREATE TABLE dbo.Movie
(
    MovieId INT NOT NULL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    genres VARCHAR(200) NOT NULL

);
GO
-- import to Movie
-- TODO: change the path to your local file
BULK INSERT dbo.Movie
FROM '/home/movies.csv'
WITH
(
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
)
GO

--  Movie_Msg table for MovieId, title, pub_date
IF OBJECT_ID('dbo.MovieMsg', 'U') IS NOT NULL
DROP TABLE dbo.MovieMsg
GO
CREATE TABLE dbo.MovieMsg
(
    MovieId INT NOT NULL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    pub_date VARCHAR(10) 
);
GO

-- process Movie to produce table MovieMsg
INSERT INTO dbo.MovieMsg(MovieId, title, pub_date)
SELECT MovieId, (CASE WHEN patindex('%([0-9][0-9][0-9][0-9])%', title) = 0
                THEN title
                ELSE substring(title, 1, patindex('%([0-9][0-9][0-9][0-9])%', title) - 2) end)  as TITLE,
                (CASE WHEN patindex('%([0-9][0-9][0-9][0-9])%', title) = 0
                THEN NULL
                ELSE substring(title, patindex('%([0-9][0-9][0-9][0-9])%', title) + 1, 4) end) as PUB_DATE
FROM dbo.Movie
GO

-- create table MovieType for (MovieId, genres)
IF OBJECT_ID('dbo.MovieType', 'U') IS NOT NULL
DROP TABLE dbo.MovieType
GO
-- Create the table in the specified schema
CREATE TABLE dbo.MovieType
(
    MovieId INT NOT NULL,
    genres VARCHAR(100) NOT NULL,
    PRIMARY KEY(MovieId, genres),
    FOREIGN KEY(MovieId) REFERENCES dbo.MovieMsg(MovieId)
    -- specify more columns here
);
GO

--process Movie to produce table MovieType
DECLARE @id INT
DECLARE @genres VARCHAR(200)
DECLARE  my_curs cursor for
SELECT MovieId, genres
FROM dbo.Movie
OPEN  my_curs
FETCH NEXT FROM my_curs INTO @id, @genres
WHILE  @@fetch_status = 0
BEGIN
    INSERT INTO dbo.MovieType
        (MovieId, genres)
    SELECT *
    FROM dbo.splitall(@id, @genres, '|')
    FETCH NEXT FROM my_curs INTO @id, @genres
END
CLOSE  my_curs
DEALLOCATE my_curs
GO
---Tag

--temporary table
IF OBJECT_ID('dbo.Tags_Tmp', 'U') IS NOT NULL
DROP TABLE dbo.Tags_Tmp
GO

CREATE TABLE dbo.Tags_Tmp
(
    UserId INT NOT NULL,
    MovieId INT NOT NULL,
    Tag VARCHAR(500) NOT NULL,
    TagTime BIGINT NOT NULL,
    FOREIGN KEY(MovieId) REFERENCES dbo.MovieMsg(MovieId)
);
GO

--- Tag

IF OBJECT_ID('dbo.Tags', 'U') IS NOT NULL
DROP TABLE dbo.Tags
GO
-- Create the table in the specified schema
CREATE TABLE dbo.Tags
(
    TagId INT identity(1,1), -- self-increasing key
    UserId INT NOT NULL,
    MovieId INT NOT NULL,
    Tag VARCHAR(500) NOT NULL,
    TagTime DATETIME NOT NULL,
    FOREIGN KEY(MovieId) REFERENCES dbo.MovieMsg(MovieId)
);
GO

-- import data into table Tags_Tmp
-- TODO: change path to your local file
BULK INSERT dbo.Tags_Tmp
FROM '/home/tags.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
)
GO

--import data from Tmp to Tags
INSERT dbo.Tags(UserId, MovieId, Tag, TagTime)
SELECT UserId, MovieId, Tag, DATEADD(second, TagTime, {d '1970-01-01'})
FROM dbo.Tags_Tmp
DROP TABLE dbo.Tags_Tmp -- drop temporary table
GO

-- create table Rating，
IF OBJECT_ID('dbo.Ratings_Tmp', 'U') IS NOT NULL
DROP TABLE dbo.Ratings_Tmp
GO
-- Create the table in the specified schema
CREATE TABLE dbo.Ratings_Tmp
(
    UserId INT NOT NULL,
    MovieId INT NOT NULL,
    Rate REAL NOT NULL,
    RateTime BIGINT NOT NULL, --- temporary timestamp
    PRIMARY KEY(UserId, MovieId),
    FOREIGN KEY(MovieId) REFERENCES dbo.MovieMsg(MovieId)
);
GO

IF OBJECT_ID('dbo.Ratings', 'U') IS NOT NULL
DROP TABLE dbo.Ratings
GO
-- Create the table in the specified schema
CREATE TABLE dbo.Ratings
(
    UserId INT NOT NULL,
    MovieId INT NOT NULL,
    Rate REAL NOT NULL,
    RateTime DATETIME NOT NULL,
    --- temporary timestamp
    PRIMARY KEY(UserId, MovieId),
    FOREIGN KEY(MovieId) REFERENCES dbo.MovieMsg(MovieId)
);
GO

BULK INSERT dbo.Ratings_Tmp
FROM '/home/ratings.csv'
WITH
(
    FORMAT = 'CSV', 
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
)
GO

INSERT dbo.Ratings(UserId, MovieId, Rate, RateTime)
SELECT UserId, MovieId, Rate, DATEADD(second, RateTime, {d '1970-01-01'})
FROM dbo.Ratings_Tmp
DROP TABLE dbo.Ratings_Tmp -- drop temporary table
GO

--- create two tables to record the sequence index of movieId and UserId respectively
--- used to produce the matrix

IF OBJECT_ID('dbo.MovieSeq', 'U') IS NOT NULL
DROP TABLE dbo.MovieSeq
GO

CREATE TABLE dbo.MovieSeq
(
    MSeq  INT identity(1, 1),
    MovieId INT NOT NULL
);
GO

-- insert
INSERT INTO dbo.MovieSeq(MovieId)
SELECT MovieId FROM dbo.MovieMsg ORDER BY MovieId
CREATE INDEX Movie_index ON dbo.MovieSeq(MovieId)
GO

IF OBJECT_ID('dbo.UserSeq', 'U') IS NOT NULL
DROP TABLE dbo.UserSeq
GO

CREATE TABLE dbo.UserSeq
(
    USeq INT identity(1, 1),
    UserId INT NOT NULL
);
GO

-- insert
INSERT INTO dbo.UserSeq(UserId)
SELECT DISTINCT UserId FROM dbo.Ratings ORDER BY UserId
CREATE INDEX User_index ON dbo.UserSeq(UserId)
GO
