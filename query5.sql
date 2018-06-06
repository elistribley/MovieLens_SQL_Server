USE movies
GO

-- only in dbo.ratings 
SELECT COUNT(*) col_num, STDEV(Ratings.Rate) std_dev,AVG(Ratings.Rate) avg_rate, MAX(Ratings.Rate) max_rate, MIN(Ratings.Rate) min_rate
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId not in
(SELECT Tags.MovieId FROM dbo.Tags Tags)

-- rating range: 0.5 - 5
SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId not in
(SELECT Tags.MovieId FROM dbo.Tags Tags)
    AND Ratings.Rate >= 0.5 AND Ratings.Rate < 1

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId not in
(SELECT Tags.MovieId FROM dbo.Tags Tags)
    AND Ratings.Rate >= 1 AND Ratings.Rate < 1.5

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId not in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 1.5 AND Ratings.Rate < 2.0

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId not in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 2.0 AND Ratings.Rate < 2.5

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId not in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 2.5 AND Ratings.Rate < 3.0

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId not in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 3.0 AND Ratings.Rate < 3.5

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId not in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 3.5 AND Ratings.Rate < 4.0

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId not in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 4.0 AND Ratings.Rate < 4.5

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId not in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 4.5 AND Ratings.Rate <= 5.0

-- in both dbo.ratings and dbo.tags
SELECT COUNT(*) col_num, STDEV(Ratings.Rate) std_dev,AVG(Ratings.Rate) avg_rate, MAX(Ratings.Rate) max_rate, MIN(Ratings.Rate) min_rate
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId  in
(SELECT Tags.MovieId FROM dbo.Tags Tags)

-- rating range: 0.5 - 5
SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 0.5 AND Ratings.Rate < 1

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 1 AND Ratings.Rate < 1.5

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 1.5 AND Ratings.Rate < 2.0

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 2.0 AND Ratings.Rate < 2.5

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 2.5 AND Ratings.Rate < 3.0

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 3.0 AND Ratings.Rate < 3.5

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 3.5 AND Ratings.Rate < 4.0

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 4.0 AND Ratings.Rate < 4.5

SELECT COUNT(*) col_num
FROM dbo.Ratings Ratings
WHERE Ratings.MovieId in
(SELECT Tags.MovieId
    FROM dbo.Tags Tags)
    AND Ratings.Rate >= 4.5 AND Ratings.Rate <= 5.0

GO
-- results
-- only
-- 190714	1.1723958752106	2.91602346969808	5	0.5

-- 9661
-- 15084
-- 5724
-- 22965
-- 15783
-- 48641
-- 22850
-- 30304
-- 19702

-- both
-- 25833575 1.06330397521705	3.53260888204594	5	0.5

-- 395236
-- 828226
-- 397883
-- 1739475
-- 1239575
-- 5208081
-- 3093363
-- 6968498
-- 5963238

-- 	Total execution time: 00:01:09.471