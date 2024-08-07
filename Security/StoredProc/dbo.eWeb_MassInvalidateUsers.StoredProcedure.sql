USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_MassInvalidateUsers]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_MassInvalidateUsers]
AS
BEGIN

	UPDATE mi
	SET UserID = m.UserId
	FROM dbo.eWebMassInvalidations mi
	INNER JOIN aspnet_Membership m ON m.Email = mi.Email
	WHERE mi.UserID IS NULL

	DECLARE @users TABLE(UserID UNIQUEIDENTIFIER, RowNum INTEGER PRIMARY KEY CLUSTERED (RowNum, UserID))

	INSERT INTO @users
	SELECT DISTINCT UserID, ROW_NUMBER() OVER (ORDER BY UserID) AS rn
	FROM dbo.eWebMassInvalidations
	WHERE UserID IS NOT NULL AND IsProcessed = 0

	DECLARE @rn INT; SET @rn = 1
	DECLARE @UserID UNIQUEIDENTIFIER

	SELECT COUNT(*) AS [NotIsApprovedBefore] FROM aspnet_Membership WHERE IsApproved=0
	SELECT COUNT(*) AS [ScreenAccessCtBefore] FROM eWebScreenAccess

	WHILE(@rn <= (SELECT MAX(RowNum) FROM @users))
	BEGIN
		SELECT @UserID = UserID FROM @users WHERE RowNum = @rn
	
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

		UPDATE aspnet_Membership SET IsApproved = 0 WHERE UserId = @UserID

		INSERT INTO SNSQueue(UserID, UpdateDate, CreateDate, Processed)
		SELECT @UserID, GETDATE(), GETDATE(), 0

		SET @rn = @rn + 1
	END

	UPDATE dbo.eWebMassInvalidations SET IsProcessed = 1 WHERE IsProcessed = 0 AND UserID IS NOT NULL

	SELECT @rn - 1 AS [UserIDsProcessed]

	SELECT COUNT(*) AS [NotIsApprovedAfter] FROM aspnet_Membership WHERE IsApproved=0
	SELECT COUNT(*) AS [ScreenAccessCtAfter] FROM eWebScreenAccess
END
GO
