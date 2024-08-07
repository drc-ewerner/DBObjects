USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_GetPermissionSetID]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
	Returns the @PermissionSetID for a given
	AdministrationID and RoleName if one exists.
*/

CREATE PROCEDURE [dbo].[eWeb_GetPermissionSetID] 
(
	@AdminID int
	,@RoleName varchar(50)
	,@PermissionSetName varchar(50)
)
AS

BEGIN
	DECLARE @PermissionSetID AS INT
	DECLARE @RoleID AS INT
	DECLARE @PermissionID AS INT
	DECLARE @msg varchar(500)

	/*Set @RoleID*/
	IF(Select COUNT(*) FROM [dbo].[eWebRole] WHERE RoleName = @RoleName) = 1
	BEGIN
		SELECT @RoleID = RoleID FROM [dbo].[eWebRole] WHERE RoleName = @RoleName

		/*Insert if does not exist*/
		IF (SELECT COUNT(*) FROM [dbo].[eWebPermissionSet] WHERE RoleID = @RoleID AND AdminID = @AdminID AND PermissionSetName = @PermissionSetName) = 0
			INSERT [dbo].[eWebPermissionSet] (PermissionSetName, AdminID, RoleID) VALUES (@PermissionSetName, @AdminID, @RoleID)
	
		/*Get PermissionSetID*/
		SELECT @PermissionSetID = PermissionSetID FROM [dbo].[eWebPermissionSet] WHERE RoleID = @RoleID and AdminID = @AdminID and PermissionSetName = @PermissionSetName

		IF(ISNULL(@PermissionSetID, '') = '')
		BEGIN
			SET @msg = 'Could not find PermissionSetID for @AdminID = ' + @AdminID + ' and @RoleID = ' + @RoleID
			RAISERROR (@msg, 18, 0)
			RETURN -1
		END
	END
	ELSE
	BEGIN
		SET @msg = 'Could not find RoleID for @RoleName = ' + @RoleName
		RAISERROR (@msg, 18, 0)
		RETURN -1
	END

	RETURN @PermissionSetID
END
GO
