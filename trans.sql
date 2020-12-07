-- Column Created 

ALTER TABLE [Baseball_Fall_2020].[dbo].[People]
ADD pds45_Total_Games_Played int;

-- Column Created

ALTER TABLE [Baseball_Fall_2020].[dbo].[People]
ADD pds45_Date_Last_Update date;

-- Declaring variables

DECLARE     @updateCount bigint 
DECLARE     @PlayerID varchar(50)
DECLARE		@Total_Games int
DECLARE		@STOP int
DECLARE		@today date
SET			@today = convert(date, getdate())
SET			@updateCount = 0
SET			@STOP = 0
PRINT 'TRANSACTION UPDATE COMMAND START TIME - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))

-- Declaring Cursor

DECLARE updatecursor CURSOR STATIC FOR
	SELECT [Appearances].[playerID], SUM([Appearances].[G_all]) AS Total_Games
	FROM [Baseball_Fall_2020].[dbo].[People], [Baseball_Fall_2020].[dbo].[Appearances]
	WHERE [People].[playerID] = [Appearances].[playerID]
	AND (pds45_Date_Last_Update <> @today OR pds45_Date_Last_Update is NULL)
	GROUP BY [Appearances].[playerID];
SELECT @@CURSOR_ROWS AS 'Number of Cursor Rows After Declare'
PRINT 'Declare Cursor Complete Time - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))

-- Open Cursor

OPEN updatecursor
    SELECT @@CURSOR_ROWS AS 'Number of Cursor Rows'
    FETCH NEXT FROM updatecursor INTO @PlayerID, @Total_Games
    WHILE @@fetch_status = 0 AND @STOP = 0
    BEGIN

-- Begin the first record transaction

    if @updateCount = 0
    BEGIN 
      PRINT 'Begin Transaction At Record - ' + RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
      BEGIN TRANSACTION
    END

-- Updating record

UPDATE [Baseball_Fall_2020].[dbo].[People]
	SET pds45_Total_Games_Played = @Total_Games, pds45_Date_Last_Update = @today
	WHERE playerID = @PlayerID
    SET @updateCount = @updateCount + 1

-- Abend at Record 19690

   IF @updateCount = 19690
	BEGIN
  	SET @STOP = 1
	END

-- Commit every 100 records and start new transaction

    IF @updateCount % 1000 = 0 
     BEGIN
     PRINT 'COMMIT TRANSACTION - ' + RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))

-- With the previous group done we need the next

    PRINT 'END OLD TRANSACTION AT RECORD - ' + RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
        COMMIT TRANSACTION
        BEGIN TRANSACTION
    END
        FETCH NEXT FROM updatecursor INTO @PlayerID, @Total_Games
    END
    IF @STOP <> 1
    BEGIN

-- When to end COMMIT final

    PRINT 'FINAL COMMIT TRANSACTON FOR RECORD - ' + RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
     COMMIT TRANSACTION
    END
	IF @STOP = 1
    BEGIN

-- Rollback to last COMMIT

    PRINT 'ROLLBACK STARTED FOR TRANSACTION AT RECORD - ' + RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
     ROLLBACK TRANSACTION
    END

    CLOSE updatecursor
    DEALLOCATE updatecursor
Print 'TRANSACTION UPDATE COMMAND END TIME - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
SET nocount off;
_
SELECT [playerID], [pds45_Total_Games_Played],[pds45_Date_Last_Update]
FROM [Baseball_Fall_2020].[dbo].[People]


