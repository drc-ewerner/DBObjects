USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_GetUserIdsFromEmailCSV]    Script Date: 1/12/2022 2:05:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_GetUserIdsFromEmailCSV](@UserNames VARCHAR(MAX)) AS
BEGIN
	DECLARE @users TABLE(Email NVARCHAR(256) PRIMARY KEY CLUSTERED(Email))

	INSERT INTO @users
	SELECT * FROM dbo.Split(@UserNames, ',')

	SELECT u.Email, au.UserId
	FROM @users u
	INNER JOIN aspnet_Users au ON au.UserName = u.Email
END

GO
