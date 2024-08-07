USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[vw_SC_UserList_HasLoggedIn]    Script Date: 7/2/2024 9:45:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_SC_UserList_HasLoggedIn]
AS
SELECT     dbo.aspnet_Membership.UserId, 1 AS HasLoggedIn
FROM         dbo.aspnet_Membership INNER JOIN
                      dbo.aspnet_Users ON dbo.aspnet_Membership.UserId = dbo.aspnet_Users.UserId INNER JOIN
                      dbo.aspnet_UsersInRoles ON dbo.aspnet_Users.UserId = dbo.aspnet_UsersInRoles.UserId INNER JOIN
                      dbo.aspnet_Roles ON dbo.aspnet_UsersInRoles.RoleId = dbo.aspnet_Roles.RoleId
WHERE     (CHARINDEX('ChangedOriginalPassword', dbo.aspnet_Roles.RoleName) <> 0)
GO
