USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_AddPermSetScreen]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[eWeb_AddPermSetScreen]
    @PermissionSetID   int
   ,@ScreenName        varchar(100)

AS

DECLARE @PermissionID      int
DECLARE @AdministrationID  int
DECLARE @msg               varchar(500)
  
IF (SELECT COUNT(*) FROM eWebScreen WHERE ScreenName = @ScreenName) <> 1
  BEGIN
    SET @msg = 'Could not determine ''PermissionID'' for @ScreenName=' + @ScreenName
    RAISERROR (@msg, 18, 0)
    RETURN -1
  END

SELECT @PermissionID = PermissionID
FROM eWebScreen 
WHERE ScreenName = @ScreenName

SELECT @AdministrationID = AdminID
FROM eWebPermissionSet
WHERE PermissionSetID = @PermissionSetID

IF (SELECT COUNT(*) FROM eWebAdminScreen sa JOIN eWebScreen s ON sa.ScreenCode = s.ScreenCode WHERE s.PermissionID = @PermissionID AND sa.AdminId = @AdministrationID) <> 1
  BEGIN
    SET @msg = 'Could not find ''eWebAdminScreen'' record for @PermissionSetID=' + CONVERT(varchar(20), @PermissionSetID) + ', @ScreenName=' + @ScreenName
    RAISERROR (@msg, 18, 0)
    RETURN -1
  END
  
IF (SELECT COUNT(*) FROM dbo.eWebPermissionSetScreen 
    WHERE PermissionID = @PermissionID AND PermissionSetID = @PermissionSetID) = 0
  BEGIN
    INSERT INTO dbo.eWebPermissionSetScreen (PermissionSetID, PermissionID)
    VALUES (@PermissionSetID, @PermissionID)
    IF @@ROWCOUNT <> 1
      BEGIN
        SET @msg = 'Could not add specified ''eWebPermissionSetScreen'' record for @PermissionSetID=' + CONVERT(varchar(20), @PermissionSetID) + ', @ScreenName=' + @ScreenName
        RAISERROR (@msg, 18, 0)
        RETURN -1
      END
  END
       
GO
