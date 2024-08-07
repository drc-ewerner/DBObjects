USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_AddPermSetScreenV2]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[eWeb_AddPermSetScreenV2]
    @PermissionSetID int
   ,@ScreenCode varchar(100)

AS

DECLARE @PermissionID int
DECLARE @AdministrationID int
DECLARE @msg varchar(500)


/*Filter for n-dash and m-dash characters. Replace with regular dash.*/
Set @ScreenCode = Replace(Replace(@ScreenCode, nchar(8212), '-'), nchar(8211), '-')


IF (isnull(@ScreenCode,'') = '')
BEGIN
    SET @msg = '@ScreenCode was not specified and is required.'
    RAISERROR (@msg, 18, 0)
    RETURN -1
END
ELSE
BEGIN
    IF (SELECT COUNT(*) FROM [dbo].[eWebScreen] WHERE ScreenCode = @ScreenCode) <> 1
    BEGIN
        SET @msg = 'Could not determine ''PermissionID'' for @ScreenCode=' + @ScreenCode 
        RAISERROR (@msg, 18, 0)
        RETURN -1
    END
    ELSE
	BEGIN
        SELECT @PermissionID = PermissionID
        FROM [dbo].[eWebScreen]
        WHERE ScreenCode = @ScreenCode 
	END
END
              

SELECT @AdministrationID = AdminID
FROM [dbo].[eWebPermissionSet]
WHERE PermissionSetID = @PermissionSetID

IF (SELECT COUNT(*) FROM [dbo].[eWebAdminScreen] sa JOIN [dbo].[eWebScreen] s ON sa.ScreenCode = s.ScreenCode WHERE s.PermissionID = @PermissionID AND sa.AdminId = @AdministrationID) <> 1
BEGIN
	SET @msg = 'Error: Could not find ''eWebAdminScreen'' record for @PermissionSetID=' + CONVERT(varchar(20), @PermissionSetID) + ', @ScreenCode=' + @ScreenCode
	RAISERROR (@msg, 18, 0)
	RETURN -1
END
  
IF (SELECT COUNT(*) FROM [dbo].[eWebPermissionSetScreen] WHERE PermissionID = @PermissionID AND PermissionSetID = @PermissionSetID) = 0
BEGIN
	INSERT INTO [dbo].[eWebPermissionSetScreen] (PermissionSetID, PermissionID)
	VALUES (@PermissionSetID, @PermissionID)

	IF @@ROWCOUNT <> 1
	BEGIN
		SET @msg = 'Could not add specified ''eWebPermissionSetScreen'' record for @PermissionSetID=' + CONVERT(varchar(20), @PermissionSetID) + ', @ScreenCode=' + @ScreenCode + '
		Reason: Insert failed.'
		RAISERROR (@msg, 18, 0)
		RETURN -1
	END
END
GO
