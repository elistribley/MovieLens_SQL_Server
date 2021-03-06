USE master
GO
DROP DATABASE IF EXISTS movies
CREATE DATABASE movies
GO
USE movies
---register the function
IF OBJECT_ID (N'dbo.splitall', N'IF') IS NOT NULL  
    DROP FUNCTION dbo.splitall;  
GO
CREATE FUNCTION dbo.splitall(@Id INT,
	@String VARCHAR(MAX),
	@Delimiter VARCHAR(MAX)
) RETURNS @temptable TABLE (Id INT,
    items VARCHAR(MAX)) AS
BEGIN
    DECLARE @idx INT=1
    DECLARE @slice VARCHAR(MAX)
    IF LEN(@String) < 1 OR LEN(ISNULL(@String,'')) = 0
		RETURN
    WHILE @idx != 0
	BEGIN
        SET @idx = CHARINDEX(@Delimiter,@String)
        IF @idx != 0
			SET @slice = LEFT(@String,@idx - 1)
		ELSE
			SET @slice = @String
        IF LEN(@slice) > 0
			INSERT INTO @temptable
            (Id, items)
        VALUES(@Id, @slice)
        SET @String = RIGHT (@String, LEN(@String) - @idx)
        IF LEN(@String) = 0
			BREAK
    END
    RETURN
END
