USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[vw_SC_UserList]    Script Date: 7/2/2024 9:45:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_SC_UserList]

AS

SELECT DISTINCT 
	[m].[UserId],
	[p].[ProfileId],
	[d].[FirstName],
	[p].[DistrictCode] AS District,
	[p].[SchoolCode] AS School,
	[d].[LastName],
	[m].[Email],
	[m].[IsLockedOut],
	[m].[IsApproved],
	[p].[Role] AS userRole,
	CONVERT(BIT, CASE
				WHEN [l].[HasLoggedIn] IS NULL THEN 0
				ELSE 1
				END) AS HasUserLoggedIn,
	[m].[CreateDate],
	[p].[AdminId],
	[m].[LastLoginDate], 
	[m].[LastLockoutDate],
	[m].[LastPasswordChangedDate]
FROM
	[dbo].[aspnet_Membership] AS [m]
	INNER JOIN [dbo].[eWebUserDemographic] AS d ON [m].[UserId] = [d].[UserId]
	LEFT JOIN [dbo].[eWebUserProfile] AS [p] ON [m].[UserId] = [p].[UserId]
	LEFT JOIN [dbo].[vw_SC_UserList_HasLoggedIn] AS [l] ON [m].[UserId] = [l].[UserId]
WHERE [m].[IsDeleted] = 0


GO
