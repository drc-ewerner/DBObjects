USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_User_ChangeEmailForReUse]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[eWeb_User_ChangeEmailForReUse](@userID UNIQUEIDENTIFIER)
AS
BEGIN
	IF @userID IS NOT NULL AND @userID <> '00000000-0000-0000-0000-000000000000'
	BEGIN

		UPDATE m
		SET Email = Email + '.deleted', LoweredEmail = LoweredEmail + '.deleted', IsApproved = 0, IsLockedOut = 1
			, LastLockoutDate = GETDATE()
		FROM aspnet_Membership m
		WHERE m.UserId = @userID

		UPDATE u
		SET UserName = UserName + '.deleted', LoweredUserName = LoweredUserName + '.deleted', LastActivityDate = GETDATE()
		FROM aspnet_Users u
		WHERE u.UserId = @userID

	END
END
GO
