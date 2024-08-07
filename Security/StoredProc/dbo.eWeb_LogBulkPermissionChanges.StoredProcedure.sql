USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_LogBulkPermissionChanges]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[eWeb_LogBulkPermissionChanges]
	@Usernames XML,
	@UserRole NVARCHAR(50),
	@UpdaterUsername NVARCHAR(255),
	@AdminId INT,
	@PermissionList XML,
	@Action NVARCHAR(10)
AS
BEGIN
	DECLARE @UserID UNIQUEIDENTIFIER
	DECLARE @UpdaterUserId UNIQUEIDENTIFIER
	DECLARE @AuditId INT

	SELECT am.UserId As UserID
	  INTO #Users
	  FROM @Usernames.nodes('//ArrayOfString/string') Tbl(Col) 
		 INNER JOIN aspnet_Users am ON am.LoweredUserName = Tbl.Col.value('.', 'varchar(100)')

	SELECT @UpdaterUserId = UserId FROM aspnet_Users WHERE LoweredUserName = LOWER(@UpdaterUsername)

	SELECT es.PermissionID As PermissionID, Tbl.Col.value('.', 'varchar(100)') AS PermissionName
	  INTO #Permissions
	  FROM @PermissionList.nodes('//ArrayOfString/string') Tbl(Col) 
		 INNER JOIN eWebScreen es ON es.ScreenCode = Tbl.Col.value('.', 'varchar(100)')

	DECLARE userCursor CURSOR  
		FOR SELECT * FROM #Users
	OPEN userCursor
	FETCH NEXT FROM userCursor
	INTO @UserID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO ewebUserAudit (UserId,  ChangedBy)
		VALUES					  (@UserID, @UpdaterUserId)

		SET @AuditId = SCOPE_IDENTITY()

		INSERT INTO eWebUserPermissionAudit (UserAuditID, AdminID, Role, PermissionID, [Action])
		SELECT @AuditId, @AdminId, @UserRole, p.PermissionID, @Action
		  FROM #Permissions p

		FETCH NEXT FROM userCursor
		INTO @UserID
	END
	CLOSE userCursor
	DEALLOCATE userCursor

	DROP TABLE #Users 
	DROP TABLE #Permissions 
END
GO
