USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_ReactivateUserInsertPerm]    Script Date: 1/12/2022 2:05:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_ReactivateUserInsertPerm](@userID UNIQUEIDENTIFIER) AS

BEGIN
	/* add permissions back in */
	INSERT INTO eWebScreenAccess(ProfileId, PermissionID)
	SELECT r.ProfileId, r.PermissionId
	FROM eWebScreenAccessInactive r
	WHERE r.UserId = @userid
		AND NOT EXISTS(SELECT * FROM eWebScreenAccess chk
						WHERE chk.ProfileId = r.ProfileId AND chk.PermissionId = r.PermissionId)
						AND EXISTS(SELECT * FROM eWebUserProfile chk2 WHERE chk2.ProfileID = r.ProfileID)

	SELECT @@ROWCOUNT

	DELETE FROM eWebScreenAccessInactive WHERE UserId = @userID
END
GO
