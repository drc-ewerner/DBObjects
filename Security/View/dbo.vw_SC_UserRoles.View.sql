USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[vw_SC_UserRoles]    Script Date: 7/2/2024 9:45:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_SC_UserRoles]
AS
select ur.UserId, r.roleName
from aspnet_UsersInRoles ur
	INNER JOIN aspnet_Roles r ON ur.RoleId = r.RoleId
GO
