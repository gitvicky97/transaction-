--Creating a total_Salary column in the PEOPLE table using Triggers
use Baseball_Spring_2020


IF not exists (Select *
			   From INFORMATION_SCHEMA.COLUMNS
			   Where TABLE_NAME = 'People' and COLUMN_NAME = 'ra654_Total_Salary')
BEGIN
    ALTER TABLE People
    ADD ra654_Total_Salary INTEGER;
END;
GO

--Creating a average_salary column in the PEOPLE table using Triggers


IF not exists (SELECT *
			   FROM INFORMATION_SCHEMA.COLUMNS
			   WHERE TABLE_NAME = 'People' and COLUMN_NAME = 'ra654_Average_Salary')
BEGIN
    ALTER TABLE People
    ADD ra654_Average_Salary INTEGER;
END;
GO

SELECT * FROM People

--Average Salary 
UPDATE People
	   SET ra654_Average_Salary = Total.Avg_Salary FROM (SELECT playerID, Avg(salary) AS Avg_Salary
													 FROM Salaries
													 GROUP BY playerID) AS Total, People
	  where Total.playerID=People.playerID		
GO

--Total Salary 
UPDATE People
	   SET ra654_Total_Salary = Total.Tot_Salary FROM (SELECT playerID, Sum(salary) AS Tot_Salary
													 FROM Salaries
													 GROUP BY playerID) AS Total, People
	  WHERE Total.playerID=People.playerID		
GO

-- Deleting trigger
IF EXISTS (
    SELECT *
    FROM sys.objects
    WHERE [type] = 'TR' AND [name] = 'ra654_TotalSalary'
    )
    DROP TRIGGER ra654_TotalSalary;
GO

-- Creating trigger
CREATE TRIGGER ra654_TotalSalary
	ON Salaries AFTER INSERT, UPDATE, DELETE
	AS
BEGIN
	IF EXISTS(SELECT * FROM inserted) and EXISTS (SELECT * FROM deleted) 
	BEGIN
   		UPDATE People 
		SET ra654_Total_Salary = (ra654_Total_Salary - d.salary + i.salary)
			FROM deleted d, inserted i
			WHERE People.playerid = d.playerid and People.playerid = i.playerID;
		UPDATE People 
		SET ra654_Average_Salary = (a.Avg_Salary)
			FROM (SELECT s.playerid, AVG(s.salary) AS Avg_Salary
						FROM salaries s, inserted i
						WHERE s.playerid = i.playerID
						GROUP BY s.playerid) A
			WHERE people.playerid = a.playerid
	END

	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted) 
	BEGIN
		UPDATE People 
		SET ra654_Total_Salary = (ra654_Total_Salary + i.salary)
			FROM inserted i
			WHERE People.playerid = i.playerID;
		UPDATE People 
		SET ra654_Average_Salary = (a.Avg_Salary)
			FROM (SELECT s.playerid, AVG(s.salary) AS Avg_Salary
						FROM salaries s, inserted i
						WHERE s.playerid = i.playerID
						GROUP BY s.playerid) A
			WHERE people.playerid = a.playerid
	END
	IF NOT EXISTS(SELECT * FROM inserted) and EXISTS (SELECT * FROM deleted) 
	BEGIN
		UPDATE People 
		SET ra654_Total_Salary = (ra654_Total_Salary - d.salary)
			FROM deleted d
			WHERE People.playerid = d.playerID
		UPDATE People 
		SET ra654_Average_Salary = (a.Avg_Salary)
			FROM (SELECT s.playerid, AVG(s.salary) AS Avg_Salary
						FROM salaries s, deleted d
						WHERE s.playerid = d.playerID
						GROUP BY s.playerid) A
			WHERE people.playerid = a.playerid
	END
END

GO


-- Test delete
SELECT playerid, ra654_Total_Salary FROM People WHERE playerid ='aardsda01'
SELECT * FROM salaries WHERE playerid ='aardsda01' and yearid = 2004
DELETE FROM salaries WHERE playerid ='aardsda01' and yearid = 2004
SELECT playerid, ra654_Total_Salary FROM People WHERE playerid ='aardsda01'

-- Test insert
SELECT playerid, ra654_Total_Salary FROM People WHERE playerid ='aardsda01'
INSERT INTO  Salaries  VALUES ('2003', 'ATL', 'AL', 'aardsda01', '500000','35000','20000')
SELECT playerid, ra654_Total_Salary FROM People WHERE playerid ='aardsda01'

-- Test update
SELECT playerid, ra654_Total_Salary, ra654_Average_Salary FROM People WHERE playerid ='aardsda01'
SELECT * FROM salaries WHERE playerid ='aardsda01' and yearid = 2008
UPDATE salaries 
	SET salary = 1000000 WHERE playerid ='aardsda01' and yearid = 2008
SELECT playerid, ra654_Total_Salary, ra654_Average_Salary FROM People WHERE playerid ='aardsda01'




