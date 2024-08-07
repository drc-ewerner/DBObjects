USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[vw_SC_UserList_AddedByUser]    Script Date: 7/2/2024 9:45:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_SC_UserList_AddedByUser]
AS
SELECT     m.UserId,
			CASE when r.RoleName LIKE 'AddedByUser of %' THEN SUBSTRING(r.RoleName, 16, 256)
				else '' end AS AddeByUser
FROM         dbo.aspnet_Membership m 
	INNER JOIN dbo.aspnet_Users u ON m.UserId = u.UserId 
	INNER JOIN dbo.aspnet_UsersInRoles ur ON u.UserId = ur.UserId 
	INNER JOIN dbo.aspnet_Roles r ON ur.RoleId = r.RoleId
WHERE     r.RoleName LIKE 'AddedByUser of %'
GO
