USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_User_ChangeUserID]    Script Date: 7/2/2024 9:47:55 AM ******/
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
