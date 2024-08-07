USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_BulkFindUserMismatch]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[eWeb_BulkFindUserMismatch]
	 @UserData VARCHAR(max)
AS

/*Proc takes a string parameter as "userId1|email1,userId2|email2"*/

	DECLARE @users TABLE
	(
		UserID UNIQUEIDENTIFIER,
		UserName VARCHAR(4000),
		UserID_Compare  VARCHAR(100),
		UserName_Compare  VARCHAR(100),
		RowNum INTEGER PRIMARY KEY CLUSTERED (RowNum, UserID)
	)
BEGIN
	/* add the list of user data to a temp table */
	INSERT INTO @users
	SELECT 
	distinct LEFT(e.items, CHARINDEX('|', e.items) - 1) AS UserID, 
	SUBSTRING(e.items, CHARINDEX('|', e.items) + 1, LEN(e.items)) AS UserName,
	'Mismatch' AS UserID_Compare,
	'Mismatch' AS UserName_Compare,
	ROW_NUMBER() OVER (ORDER BY @UserData) AS rn
	FROM  dbo.Split(@UserData, ',') e

	/* Update UserID_Compare and UserName_Compare to Match*/
	UPDATE u
	SET UserID_Compare = 'Match'
	FROM aspnet_Membership m
	  INNER JOIN @users u 
	  ON m.userid = u.userid

	UPDATE u
	SET UserName_Compare = 'Match'
	FROM aspnet_Membership m
	  INNER JOIN @users u 
	  ON m.Email = u.UserName

	/* Look for mismatching data */
	SELECT UserID, UserName, UserID_Compare, UserName_Compare
	FROM @users
	WHERE UserID_Compare = 'Mismatch' 
		OR UserName_Compare = 'Mismatch'
END
GO
