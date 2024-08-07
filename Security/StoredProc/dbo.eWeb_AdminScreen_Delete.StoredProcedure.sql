USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_AdminScreen_Delete]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[eWeb_AdminScreen_Delete]
	@AdminID      int
   ,@ScreenCode   varchar(100)
AS

/* delete the perm from any permission sets for the admin */
DELETE 
FROM pss
FROM dbo.eWebPermissionSetScreen  pss
JOIN dbo.eWebPermissionSet        ps   ON  pss.PermissionSetID = ps.PermissionSetID
                                       AND @AdminID            = ps.AdminID
JOIN dbo.eWebScreen               s    ON  pss.PermissionID    = s.PermissionID
WHERE s.ScreenCode = @ScreenCode

/* delete the assignment of the perm from all users for the admin */
DELETE 
FROM sa
FROM dbo.eWebScreenAccess  sa
JOIN dbo.eWebUserProfile   up  ON  sa.ProfileId    = up.ProfileId
                               AND @AdminID        = up.AdminId
JOIN dbo.eWebScreen        s   ON  sa.PermissionID = s.PermissionID
WHERE s.ScreenCode = @ScreenCode

/* delete the perm from the admin */
DELETE 
FROM sa
FROM dbo.eWebAdminScreen  sa
JOIN dbo.eWebScreen       s   ON  sa.ScreenCode = s.ScreenCode
WHERE sa.AdminId   = @AdminID
 AND  s.ScreenCode = @ScreenCode
GO
