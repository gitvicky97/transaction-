create function FullName (@playerid varchar(250))
returns varchar(250)
as

BEGIN

DECLARE @fname varchar(250)
SET @fname = (SELECT (namegiven + ' ( ' + namefirst + ' ) ' + namelast) as Full_Name 
              FROM People
			  WHERE people.playerid = @playerid)

RETURN (@fname)

END


With A (teamid, playerid, Total_Hits, Totals_At_Bats, Batting_Avg) AS
       (SELECT teamid, playerid, sum(H) AS Total_Hits, sum(AB) AS Totals_At_Bats, 
	    convert(decimal(15,4), (sum(H)*1.0/sum(AB))) AS Batting_Avg
	    FROM Batting 
		GROUP BY teamid, playerid
		HAVING sum(AB) > 0)

	
SELECT A.teamid, [dbo].[FullName](P.playerid) AS Full_Name, Total_Hits, Totals_At_Bats,
       Batting_Avg, rank() OVER (PARTITION BY teamid ORDER BY Batting_Avg DESC) AS Team_Batting_Rank,
	   dense_rank() OVER(ORDER BY Batting_Avg DESC) AS All_Batting_Rank
FROM People P, A
WHERE P.playerid = A.playerid AND A.Total_Hits > 150
ORDER BY A.teamid, Team_Batting_Rank ASC