USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_InactivateUserRemovePerm]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_InactivateUserRemovePerm](@userID UNIQUEIDENTIFIER) AS
BEGIN
	/* Inactivate a user by removing all the permissions for the user */

	INSERT INTO dbo.eWebScreenAccessInactive
	SELECT p.UserId, sa.*
	FROM eWebUserProfile p
	INNER JOIN eWebScreenAccess sa ON sa.ProfileId = p.ProfileId
	WHERE p.UserId = @userID AND NOT EXISTS(SELECT * FROM eWebScreenAccessInactive chk
											WHERE chk.ScreenAccessId = sa.ScreenAccessId
												AND chk.ProfileId = sa.ProfileId
												AND chk.UserId = @userID)
	DELETE sa
	FROM eWebScreenAccess sa
	INNER JOIN eWebScreenAccessInactive r
		ON r.ScreenAccessId = sa.ScreenAccessId
			AND r.ProfileId = sa.ProfileId
			AND r.UserId = @userID

	SELECT @@ROWCOUNT
END
GO
