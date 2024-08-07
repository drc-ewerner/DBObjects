USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_Screen_InsertOrUpdate]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eWeb_Screen_InsertOrUpdate]
	@ScreenCode varchar(100)
	,@ScreenName varchar(100)
	,@Description varchar(300)
	,@IsInternalOnly bit
	,@IsDeny bit = 0
AS


/*Filter for n-dash and m-dash characters. Replace with regular dash.*/
Set @ScreenName = Replace(Replace(@ScreenName, nchar(8212), '-'), nchar(8211), '-')
Set @ScreenCode = Replace(Replace(@ScreenCode, nchar(8212), '-'), nchar(8211), '-')
Set @Description = Replace(Replace(@Description, nchar(8212), '-'), nchar(8211), '-')


IF EXISTS(Select * From [dbo].[eWebScreen] Where ScreenCode = @ScreenCode)
BEGIN
	Update [dbo].[eWebScreen]
	Set ScreenName = @ScreenName
		,[Description] = @Description
		,IsInternalOnly = @IsInternalOnly
		,IsDeny = @IsDeny
	Where ScreenCode = @ScreenCode
END
ELSE
BEGIN
	Insert Into [dbo].[eWebScreen] (ScreenCode, ScreenName, [Description], IsInternalOnly, IsDeny)
	Values (@ScreenCode, @ScreenName, @Description, @IsInternalOnly, @IsDeny)
END
GO
