USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_User_ChangeUserID]    Script Date: 1/12/2022 2:05:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_User_ChangeUserID](@UserName NVARCHAR(256), @NewUserID UNIQUEIDENTIFIER) AS
BEGIN
	UPDATE aspnet_Users SET UserId = @NewUserID WHERE UserName = @UserName

	SELECT @@ROWCOUNT AS RowsAffected
END
GO
