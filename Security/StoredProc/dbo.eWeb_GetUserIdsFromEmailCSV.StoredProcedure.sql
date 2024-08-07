USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_GetUserIdsFromEmailCSV]    Script Date: 7/2/2024 9:47:55 AM ******/
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
