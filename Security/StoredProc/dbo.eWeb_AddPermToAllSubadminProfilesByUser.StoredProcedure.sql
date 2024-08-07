USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_AddPermToAllSubadminProfilesByUser]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_AddPermToAllSubadminProfilesByUser]
	(@ParentAdminID INT, @userlist VARCHAR(MAX), @ScreenCode VARCHAR(100), @excludeAdminIdList VARCHAR(MAX) = NULL)
AS 
BEGIN
DECLARE @users TABLE(UserName NVARCHAR(256) PRIMARY KEY CLUSTERED(UserName))
DECLARE @excludeAdmins TABLE(AdminID INT PRIMARY KEY CLUSTERED(AdminID))

/* convert comma-delimited list of users to a table */    
IF LTRIM(RTRIM(@userlist))='' RETURN
INSERT INTO @users SELECT * FROM dbo.Split(@userlist, ',')
    
/* convert comma-delimited list of excludedAdmins to a table */    
SELECT @excludeAdminIdList = ISNULL(@excludeAdminIdList, '')
INSERT INTO @excludeAdmins SELECT * FROM dbo.Split(@excludeAdminIdList, ',')
    
INSERT INTO [dbo].[eWebScreenAccess]
SELECT p.ProfileId, sc.PermissionID
FROM aspnet_Users u
INNER JOIN @users ulist ON ulist.UserName = u.UserName AND ulist.UserName <> ''
INNER JOIN eWebUserProfile p on p.UserId = u.UserId
INNER JOIN eWebScreen sc ON sc.ScreenCode = @ScreenCode
INNER JOIN eWebAdministration ea ON ea.AdministrationID = p.AdminId AND ea.ParentAdministrationId = @ParentAdminID AND ea.IsParentAdministration = 0
LEFT JOIN @excludeAdmins xa ON ea.AdministrationID = xa.AdminID
WHERE NOT EXISTS(SELECT * FROM eWebScreenAccess sa2 WHERE sa2.ProfileId = p.ProfileId AND sa2.PermissionID = sc.PermissionID)
  AND xa.AdminID IS NULL
SELECT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' eWebScreenAccess rows inserted.'
SELECT ulist.UserName AS UsersNotFound
FROM @users ulist
LEFT OUTER JOIN aspnet_Users u ON u.UserName = ulist.UserName
WHERE u.UserId IS NULL
END
GO
