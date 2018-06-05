USE movies
SET NOCOUNT ON

-- 基于序列号的用户-电影关联矩阵
IF OBJECT_ID('dbo.UserMovieMatrix_seq', 'U') IS NOT NULL
DROP TABLE dbo.UserMovieMatrix_seq
GO
-- Create the table in the specified schema
CREATE TABLE dbo.UserMovieMatrix_seq
(
    USeq INT NOT NULL, 
    MSeq INT NOT NULL,
    Rate REAL NOT NULL DEFAULT 0,
	PRIMARY KEY (USeq, MSeq)
    -- specify more columns here
);
GO

INSERT INTO dbo.UserMovieMatrix_seq
SELECT dbo.UserSeq.USeq, dbo.MovieSeq.MSeq, dbo.Ratings.Rate 
FROM dbo.UserSeq, dbo.MovieSeq, dbo.Ratings
WHERE dbo.UserSeq.UserId = dbo.Ratings.UserId and dbo.MovieSeq.MovieId = dbo.Ratings.MovieId
ORDER BY dbo.UserSeq.USeq, dbo.MovieSeq.MSeq
GO

 --基于ID的用户-电影关联矩阵
 --注意要求ID为正整数
 --基于ID的矩阵相比基于序列号更大 更稀疏 但是存储为三元组占用空间是一样的

IF OBJECT_ID('dbo.UserMovieMatrix_id', 'U') IS NOT NULL
DROP TABLE dbo.UserMovieMatrix_id
GO
-- Create the table in the specified schema
CREATE TABLE dbo.UserMovieMatrix_id
(
    UserId INT NOT NULL, 
    MovieId INT NOT NULL,
    Rate REAL NOT NULL DEFAULT 0
	PRIMARY KEY (UserId, MovieId)
    -- specify more columns here
);
GO

INSERT INTO dbo.UserMovieMatrix_id
SELECT dbo.Ratings.UserId, dbo.Ratings.MovieId, dbo.Ratings.Rate 
FROM dbo.Ratings
ORDER BY dbo.Ratings.UserId, dbo.Ratings.MovieId
GO

--基于序列号的用户-用户关联矩阵
--定义两用户在同一部电影m的相似性为：f(rate1, rate2;m) = 2 / (1 + exp(rate2 - rate1)) rate2 >= rate1
--定义二者相似性为在所有共同看过的电影m上的相似性的求和

--首先定义函数f
IF OBJECT_ID(N'dbo.rateFunc', N'FN') IS NOT NULL
	DROP FUNCTION dbo.rateFunc
GO
CREATE FUNCTION dbo.rateFunc(
	@rate1 REAL,
	@rate2 REAL
)
RETURNS REAL
AS 
BEGIN
	DECLARE @tem REAL;
	SET @tem = ABS(@rate1 - @rate2);
	SET @tem = EXP(@tem);
	SET @tem = 2 / (1 + @tem);
	RETURN @tem;
END;
GO

/*
不计算并存储这个表 太大
--计算出任两个用户所有共同看过的电影以及对应打分
IF OBJECT_ID(N'dbo.UserCommonMovie', N'U') IS NOT NULL
	DROP TABLE dbo.UserCommonMovie
GO
CREATE TABLE dbo.UserCommonMovie
(
	UserId1 INT NOT NULL,
	UserId2 INT NOT NULL,
	MovieId INT NOT NULL,
	Rate1 REAL NOT NULL,
	Rate2 REAL NOT NULL,
	PRIMARY KEY (UserId1, UserId2, MovieId)
);

INSERT INTO dbo.UserCommonMovie
SELECT R1.UserId, R2.UserId, R1.MovieId, R1.Rate, R2.Rate
FROM dbo.Ratings R1, dbo.Ratings R2
WHERE R1.MovieId = R2.MovieId
AND R1.UserId <> R2.UserId
GO
*/

--基于ID的用户-用户关联矩阵
IF OBJECT_ID(N'dbo.UserUserMatrix_id', N'U') IS NOT NULL
	DROP TABLE dbo.UserUserMatrix_id
GO
CREATE TABLE dbo.UserUserMatrix_id
(
	UserId1 INT NOT NULL,
	UserId2 INT NOT NULL,
	Weights REAL NOT NULL,
	PRIMARY KEY (UserId1, UserId2)
);

INSERT INTO dbo.UserUserMatrix_id
SELECT R1.UserId, R2.UserId, SUM(dbo.rateFunc(R1.Rate, R2.Rate))
FROM dbo.Ratings R1, dbo.Ratings R2
WHERE R1.UserId <> R2.UserId
AND R1.MovieId = R2.MovieId
GROUP BY R1.UserId, R2.UserId
ORDER BY R1.UserId, R2.UserId

GO

--基于序列号的用户用户关联矩阵
--实际上完全和基于ID的一样 因为用户ID是连续的
IF OBJECT_ID(N'dbo.UserUserMatrix_seq', N'U') IS NOT NULL
	DROP TABLE dbo.UserUserMatrix_seq
GO
CREATE TABLE dbo.UserUserMatrix_seq
(
	USeq1 INT NOT NULL, 
	USeq2 INT NOT NULL,
	Weights REAL NOT NULL,
	PRIMARY KEY (USeq1, Useq2)
);

INSERT INTO dbo.UserUserMatrix_seq
SELECT US1.USeq, US2.USeq, UUM.Weights
FROM dbo.UserUserMatrix_id UUM, dbo.UserSeq US1, dbo.UserSeq US2
WHERE UUM.UserId1 = US1.UserId
AND UUM.UserId2 = US2.UserId
ORDER BY US1.USeq, US2.USeq

GO

