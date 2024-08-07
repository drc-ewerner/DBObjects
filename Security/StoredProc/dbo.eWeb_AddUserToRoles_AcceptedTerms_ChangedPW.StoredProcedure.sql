USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_AddUserToRoles_AcceptedTerms_ChangedPW]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_AddUserToRoles_AcceptedTerms_ChangedPW](@userID UNIQUEIDENTIFIER) AS
BEGIN

INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
SELECT @userID, r.RoleId 
FROM aspnet_roles r 
WHERE r.RoleName IN ('AcceptedTermsOfUse', 'ChangedOriginalPassword')
	AND NOT EXISTS(SELECT * FROM aspnet_UsersInRoles u
					WHERE u.UserId = @userID AND u.RoleId = r.RoleId)


END
GO
