USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_RemovePermFromProfiles]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_RemovePermFromProfiles](@profxml XML, @permxml XML, @approvedxml XML) AS
BEGIN

BEGIN TRY DROP TABLE #profiles END TRY BEGIN CATCH END CATCH
BEGIN TRY DROP TABLE #todel END TRY BEGIN CATCH END CATCH
BEGIN TRY DROP TABLE #approvedcodes END TRY BEGIN CATCH END CATCH

SELECT Tbl.Col.value('UserId[1]', 'VARCHAR(MAX)') AS UserIdVC
	, CAST(NULL AS uniqueidentifier) AS UserId
	, Tbl.Col.value('District[1]', 'NVARCHAR(50)') AS DistrictCode
	, Tbl.Col.value('School[1]', 'NVARCHAR(50)') AS SchoolCode
	, Tbl.Col.value('Role[1]', 'NVARCHAR(50)') AS [Role]
	, Tbl.Col.value('AdminId[1]', 'INT') AS AdminId
	, Tbl.Col.value('ID[1]', 'INT') AS ProfileId
	, Tbl.Col.value('UserName[1]', 'NVARCHAR(256)') AS UserName
	, Tbl.Col.value('FirstName[1]', 'VARCHAR(30)') AS FirstName
	, Tbl.Col.value('LastName[1]', 'VARCHAR(30)') AS LastName
	, Tbl.Col.value('Email[1]', 'NVARCHAR(256)') AS Email
	, Tbl.Col.value('IsLockedOut[1]', 'BIT') AS IsLockedOut
	, Tbl.Col.value('IsApproved[1]', 'BIT') AS IsApproved
	, Tbl.Col.value('HasLoggedIn[1]', 'BIT') AS HasLoggedIn
INTO #profiles
FROM @profxml.nodes('//UserProfile') Tbl(Col)

UPDATE p
SET UserId = m.UserId
FROM #profiles p
INNER JOIN aspnet_Membership m ON m.Email = p.Email

UPDATE p
SET ProfileId = prof.ProfileId
FROM #profiles p
INNER JOIN eWebUserProfile prof
	ON prof.UserId = p.UserId 
		AND prof.DistrictCode = p.DistrictCode 
		AND prof.SchoolCode = p.SchoolCode 
		AND prof.[Role] = p.[Role]
		AND prof.AdminId = p.AdminId
WHERE p.ProfileId = 0


CREATE CLUSTERED INDEX IX ON #profiles(ProfileId, AdminId, DistrictCode, SchoolCode)

SELECT Tbl.Col.value('.', 'varchar(100)') AS ScreenCode
INTO #todel
FROM @permxml.nodes('//ArrayOfString/string') Tbl(Col)

CREATE CLUSTERED INDEX IX ON #todel(ScreenCode)

;WITH shred AS 
(
	SELECT
		  Tbl.Col.value('UserToken[1]', 'UNIQUEIDENTIFIER') AS UserToken
		, Tbl.Col.value('AdminId[1]', 'INT') AS AdminID
		, Tbl.Col.value('DistrictCode[1]', 'NVARCHAR(50)') AS DistrictCode
		, Tbl.Col.value('SchoolCode[1]', 'NVARCHAR(50)') AS SchoolCode
		, Tbl.Col.value('ApprovedScreenCodes[1]', 'varchar(max)') AS ApprovedScreenCodes
	FROM @approvedxml.nodes('//UserApprovedScreenCodes') Tbl(Col)
)
SELECT 
	  UserToken
	, AdminID
	, DistrictCode
	, SchoolCode
	, CAST(tblapproved.items AS VARCHAR(100)) AS ScreenCode
INTO #approvedcodes
FROM shred
CROSS APPLY dbo.Split(shred.ApprovedScreenCodes, ',') tblapproved

CREATE CLUSTERED INDEX IX ON #approvedcodes(AdminID, DistrictCode, SchoolCode, ScreenCode)

DELETE sa
FROM #profiles p
INNER JOIN eWebUserProfile ep ON ep.ProfileId = p.ProfileId
INNER JOIN eWebAdminScreen eas ON eas.AdminId = p.AdminId
INNER JOIN eWebScreen sc ON sc.ScreenCode = eas.ScreenCode
INNER JOIN #todel ta ON ta.ScreenCode = eas.ScreenCode
INNER JOIN #approvedcodes ac /* only use APPROVED codes for the user */
	ON ac.AdminID = ep.AdminId
		AND ac.DistrictCode = p.DistrictCode
		AND ac.SchoolCode = p.SchoolCode
		AND ac.ScreenCode = sc.ScreenCode
INNER JOIN eWebScreenAccess sa ON sa.ProfileId = ep.ProfileId AND sa.PermissionID = sc.PermissionID 


SELECT @@ROWCOUNT
END

GO
