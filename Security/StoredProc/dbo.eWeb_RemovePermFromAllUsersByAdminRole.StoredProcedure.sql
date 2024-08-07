USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_RemovePermFromAllUsersByAdminRole]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_RemovePermFromAllUsersByAdminRole]
	@AdminID INT, @ScreenCode VARCHAR(100), @Role NVARCHAR(50)
AS
BEGIN
	DECLARE @msg                   varchar(500)
	DECLARE @permissionID int

	IF (SELECT COUNT(*) FROM eWebRole 
		WHERE RoleName = @Role) = 0
	  BEGIN
		SET @msg = 'There is no eWebRole record for @Role=' + @Role
		RAISERROR (@msg, 18, 0)
		RETURN -1
	  END

	IF (SELECT COUNT(*) FROM eWebAdministration 
		WHERE AdministrationID = @AdminID) = 0
	  BEGIN
		SET @msg = 'There is no eWebAdministration record for @AdminID=' + CONVERT(varchar(20), @AdminID)
		RAISERROR (@msg, 18, 0)
		RETURN -1
	  END

	IF (SELECT COUNT(*) FROM eWebAdminScreen 
		WHERE AdminId = @AdminID AND ScreenCode = @ScreenCode) = 0
	  BEGIN
		SET @msg = 'There is no eWebAdminScreen record for @AdminID=' + CONVERT(varchar(20), @AdminID) + ', @ScreenCode=' + @ScreenCode
		RAISERROR (@msg, 18, 0)
		RETURN -1
	  END

	SELECT @permissionID = PermissionID
	FROM eWebScreen
	WHERE ScreenCode = @ScreenCode

	IF @permissionID IS NULL
	  BEGIN
		SET @msg = 'There is no eWebScreen record for @ScreenCode=' + @ScreenCode
		RAISERROR (@msg, 18, 0)
		RETURN -1
	  END

	DELETE eWebScreenAccess
	FROM      eWebUserProfile       up
	INNER JOIN eWebScreenAccess      sa  ON up.ProfileId   = sa.ProfileId
									   AND @permissionID  = sa.PermissionID
	WHERE up.AdminId = @AdminID
	  AND up.Role = @Role

END
GO
