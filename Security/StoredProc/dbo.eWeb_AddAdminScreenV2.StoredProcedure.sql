USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_AddAdminScreenV2]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[eWeb_AddAdminScreenV2]
    @AdminID int
   ,@ScreenCode varchar(100)

AS

DECLARE @msg varchar(500)


/*If screencode is not provided, look it up and set the value.*/
IF (isnull(@ScreenCode,'') = '')
BEGIN
	SET @msg = '@ScreenCode was not specified and is required.'
	RAISERROR (@msg, 18, 0)
	RETURN -1
END
ELSE
BEGIN
	/*Filter for n-dash and m-dash characters. Replace with regular dash.*/
	Set @ScreenCode = Replace(Replace(@ScreenCode, nchar(8212), '-'), nchar(8211), '-')

	Declare @ExistsIn_eWebAdminScreen int
	Declare @ExistsIn_eWebScreen int

	Set @ExistsIn_eWebAdminScreen = (SELECT COUNT(*) FROM [dbo].[eWebAdminScreen] WHERE AdminId = @AdminID AND ScreenCode = @ScreenCode)
	Set @ExistsIn_eWebScreen = (SELECT COUNT(*) FROM [dbo].[eWebScreen] WHERE ScreenCode = @ScreenCode)

	/*If eWebScreen record exists but eWebAdminScreen does not*/
	IF (@ExistsIn_eWebScreen = 1 AND @ExistsIn_eWebAdminScreen = 0)
	BEGIN
		INSERT INTO [dbo].[eWebAdminScreen] (AdminId, ScreenCode)
		VALUES (@AdminID, @ScreenCode)

		IF @@ROWCOUNT <> 1
		BEGIN
			SET @msg = 'Error: Could not add specified ''eWebAdminScreen'' record for @AdminID=' + CONVERT(varchar(20), @AdminID) + ', @ScreenCode=' + @ScreenCode + '
			Reason: Insert failed.'
			RAISERROR (@msg, 18, 0)
			RETURN -1
		END
	END
	/*If eWebScreen does not exist*/
	ELSE IF(@ExistsIn_eWebScreen = 0)
	BEGIN
		SET @msg = 'Error: Could not add specified ''eWebAdminScreen'' record for @AdminID=' + CONVERT(varchar(20), @AdminID) + ', @ScreenCode=' + @ScreenCode + '
		Reason: eWebScreen record is missing.'
		RAISERROR (@msg, 18, 0)
		RETURN -1
	END


END
GO
