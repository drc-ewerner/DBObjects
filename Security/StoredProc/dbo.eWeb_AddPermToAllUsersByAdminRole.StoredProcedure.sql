USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_AddPermToAllUsersByAdminRole]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[eWeb_AddPermToAllUsersByAdminRole]
    @AdminID           int
   ,@Role              nvarchar(50)
   ,@ScreenCode        varchar(100)
   ,@DebugMode         bit           = 0

AS

DECLARE @msg                   varchar(500)
DECLARE @ProfileMissingPermCnt int
DECLARE @ProfilePermAddCnt     int

IF (SELECT COUNT(*) FROM eWebRole 
    WHERE RoleName = @Role) = 0
  BEGIN
    SET @msg = 'There is no eWebRole record for @Role=' + @Role
    RAISERROR (@msg, 18, 0)
    RETURN -1
  END

IF (SELECT COUNT(*) FROM eWebAdministration 
    WHERE AdministrationID = @AdminID) = 0
  BEGIN
    SET @msg = 'There is no eWebAdministration record for @AdminID=' + CONVERT(varchar(20), @AdminID)
    RAISERROR (@msg, 18, 0)
    RETURN -1
  END

IF (SELECT COUNT(*) FROM eWebAdminScreen 
    WHERE AdminId = @AdminID AND ScreenCode = @ScreenCode) = 0
  BEGIN
    SET @msg = 'There is no eWebAdminScreen record for @AdminID=' + CONVERT(varchar(20), @AdminID) + ', @ScreenCode=' + @ScreenCode
    RAISERROR (@msg, 18, 0)
    RETURN -1
  END

DECLARE @permissionID int

SELECT @permissionID = PermissionID
FROM eWebScreen
WHERE ScreenCode = @ScreenCode

IF @permissionID IS NULL
  BEGIN
    SET @msg = 'There is no eWebScreen record for @ScreenCode=' + @ScreenCode
    RAISERROR (@msg, 18, 0)
    RETURN -1
  END

SELECT up.*
INTO #Profiles
FROM      eWebUserProfile       up
LEFT JOIN eWebScreenAccess      sa  ON up.ProfileId   = sa.ProfileId
                                   AND @permissionID  = sa.PermissionID
WHERE up.AdminId          = @AdminID
  AND up.Role             = @Role
  AND sa.ScreenAccessId  IS NULL
SELECT @ProfileMissingPermCnt = @@ROWCOUNT
IF @DebugMode = 1 SELECT @ProfileMissingPermCnt AS ProfileMissingPermCnt

BEGIN TRY DROP TABLE #inserts END TRY BEGIN CATCH END CATCH

SELECT p.ProfileId
      ,@permissionID AS PermissionID
INTO #inserts
FROM #Profiles  p
INNER JOIN aspnet_Membership m 
	ON m.UserId = p.UserId
		AND m.IsApproved = 1
WHERE NOT EXISTS (SELECT 1 FROM eWebScreenAccess sa
                  WHERE sa.ProfileId    = p.ProfileId
				    AND sa.PermissionID = @permissionID)
				
INSERT INTO eWebScreenAccess (
       ProfileId
      ,PermissionID
)			
SELECT * FROM #inserts

SELECT @ProfilePermAddCnt = @@ROWCOUNT

INSERT INTO eWebUsersToSyncToECA
SELECT DISTINCT p.UserId, GETDATE(), 0 
FROM #inserts i
INNER JOIN eWebUserProfile p ON p.ProfileID = i.ProfileID
WHERE NOT EXISTS(SELECT * FROM dbo.eWebUsersToSyncToECA chk
				 WHERE chk.UserID = p.UserId AND chk.IsProcessed = 0)

DROP TABLE #inserts


SELECT @ProfilePermAddCnt = @@ROWCOUNT
IF @DebugMode = 1 SELECT @ProfilePermAddCnt AS ProfilePermAddCnt
GO
