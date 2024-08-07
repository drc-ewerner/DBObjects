USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_MassReactivateUsersByUserID]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_MassReactivateUsersByUserID]
	@UsersByID VARCHAR(4000)

AS

	DECLARE @users TABLE
	(
		UserID UNIQUEIDENTIFIER, 
		RowNum INTEGER PRIMARY KEY CLUSTERED (RowNum, UserID)
	)
	/* add the list of users to a temp table */
	INSERT INTO @users
	SELECT CAST(Items AS UNIQUEIDENTIFIER), 
	ROW_NUMBER() OVER (ORDER BY @UsersByID) AS rn
	FROM  dbo.Split(@UsersByID, ',')  

	SELECT * FROM @users 

BEGIN
	/* add permissions back based on the data in the temp table */
	INSERT INTO eWebScreenAccess(ProfileId, PermissionID)
	SELECT r.ProfileId, r.PermissionId
	FROM eWebScreenAccessInactive r
	INNER JOIN @users u ON r.UserId = u.UserID
	WHERE NOT EXISTS(SELECT * FROM eWebScreenAccess chk
						WHERE chk.ProfileId = r.ProfileId AND chk.PermissionId = r.PermissionId)
						AND EXISTS(SELECT * FROM eWebUserProfile chk2 WHERE chk2.ProfileID = r.ProfileID)
	
	UPDATE m
	SET IsApproved = 1 
	FROM aspnet_Membership m
	INNER JOIN @users u ON m.UserId = u.UserID
	
	SELECT @@ROWCOUNT AS UpdatedUsers

	DELETE a
	FROM eWebScreenAccessInactive a
	INNER JOIN @users u ON a.UserId = u.UserID

END
GO
