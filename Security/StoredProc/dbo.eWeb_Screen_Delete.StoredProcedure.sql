USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_Screen_Delete]    Script Date: 11/21/2023 8:39:10 AM ******/
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
