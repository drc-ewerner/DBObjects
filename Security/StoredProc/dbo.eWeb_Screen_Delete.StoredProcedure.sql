USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_Screen_Delete]    Script Date: 1/12/2022 2:05:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eWeb_Screen_Delete]
	@ScreenCode varchar(100)
AS


IF EXISTS(Select * From [dbo].[eWebScreen] Where ScreenCode = @ScreenCode)
BEGIN
	Delete From [dbo].[eWebScreen]
	Where ScreenCode = @ScreenCode
END
GO
