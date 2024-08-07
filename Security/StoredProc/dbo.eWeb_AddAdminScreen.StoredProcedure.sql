USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_AddAdminScreen]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[eWeb_AddAdminScreen]
    @AdminID           int
   ,@ScreenName        varchar(100)
   ,@ScreenCode        varchar(100)   =  ''

AS

DECLARE @msg        varchar(500)

IF @ScreenCode = ''
  BEGIN
    IF (SELECT COUNT(*) FROM eWebScreen WHERE ScreenName = @ScreenName) <> 1
      BEGIN
        SET @msg = 'Could not determine ''ScreenCode'' for @ScreenName=' + @ScreenName
        RAISERROR (@msg, 18, 0)
        RETURN -1
      END

    SELECT @ScreenCode = ScreenCode 
    FROM eWebScreen 
    WHERE ScreenName = @ScreenName
  END

IF (SELECT COUNT(*) FROM dbo.eWebAdminScreen 
    WHERE AdminId = @AdminID AND ScreenCode = @ScreenCode) = 0
  BEGIN
    INSERT INTO dbo.eWebAdminScreen (AdminId, ScreenCode)
    VALUES (@AdminID, @ScreenCode)
    IF @@ROWCOUNT <> 1
      BEGIN
        SET @msg = 'Could not add specified ''eWebAdminScreen'' record for @AdminID=' + CONVERT(varchar(20), @AdminID) + ', @ScreenName=' + @ScreenName
        RAISERROR (@msg, 18, 0)
        RETURN -1
      END
  END
       
GO
