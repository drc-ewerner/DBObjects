USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_LogPermissionChanges]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eWeb_LogPermissionChanges]
	@Username NVARCHAR(255),
	@UserRole NVARCHAR(50),
	@UpdaterUsername NVARCHAR(255),
	@AdminId INT,
	@PermissionList XML

AS
BEGIN
	DECLARE @UserId UNIQUEIDENTIFIER
	DECLARE @UpdaterUserId UNIQUEIDENTIFIER
	DECLARE @AuditId INT

	SELECT @UserId = UserId FROM aspnet_Users WHERE LoweredUserName = LOWER(@Username)
	SELECT @UpdaterUserId = UserId FROM aspnet_Users WHERE LoweredUserName = LOWER(@UpdaterUsername)

	INSERT INTO ewebUserAudit (UserId,  ChangedBy)
		VALUES				  (@UserId, @UpdaterUserId)

	SET @AuditId = SCOPE_IDENTITY()

	SELECT es.PermissionID As PermissionID, Tbl.Col.value('.', 'varchar(100)') AS PermissionName
	  INTO #Permissions
	  FROM @PermissionList.nodes('//ArrayOfString/string') Tbl(Col) 
		 INNER JOIN eWebScreen es ON es.ScreenCode = Tbl.Col.value('.', 'varchar(100)')

	  SELECT DISTINCT es.PermissionID, es.ScreenCode
		INTO #CurrentPermissions
		FROM eWebScreen es
			 INNER JOIN ewebScreenAccess esa ON esa.PermissionID = es.PermissionID
			 INNER JOIN eWebUserProfile eup ON esa.ProfileId = eup.ProfileId
			 INNER JOIN eWebAdminScreen eas ON eas.AdminId = eup.AdminId
			 INNER JOIN aspnet_Membership am on am.UserId = eup.UserId
	   WHERE am.Email = @Username AND eas.AdminId = @AdminId AND eup.Role = @UserRole

	INSERT INTO eWebUserPermissionAudit (UserAuditID, AdminID, Role, PermissionID, [Action])
	SELECT @AuditId, @AdminId, @UserRole, p.PermissionID, 'Add' As Action
	  FROM #Permissions p
	WHERE NOT EXISTS (SELECT cp.PermissionID FROM #CurrentPermissions AS cp WHERE p.PermissionID = cp.PermissionID);

	INSERT INTO eWebUserPermissionAudit (UserAuditID, AdminID, Role, PermissionID, [Action])
	SELECT @AuditId, @AdminId, @UserRole, cp.PermissionID, 'Remove' AS Action
	  FROM #CurrentPermissions cp
	 WHERE NOT EXISTS (SELECT PermissionID FROM #Permissions AS P WHERE cp.PermissionID = p.PermissionID) AND
		   NOT EXISTS (SELECT PermissionID FROM dbo.eWebUserPermissionAudit AS a WHERE a.UserAuditID = @AuditId AND cp.PermissionID = a.PermissionID)

	DROP TABLE #Permissions;
	DROP TABLE #CurrentPermissions;

END
GO
