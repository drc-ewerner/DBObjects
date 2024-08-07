USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[vw_SC_UserList_NotLoggedIn]    Script Date: 7/2/2024 9:45:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_SC_UserList_NotLoggedIn]
AS
SELECT DISTINCT ud.FirstName, 
	up.DistrictCode AS District, 
	up.SchoolCode AS School, 
	ud.LastName, 
	m.Email, 
	up.Role AS userRole, 
	m.CreateDate, 
	adder.AddeByUser, 
    m.LastPasswordChangedDate, 
	up.AdminId
FROM aspnet_Membership m
	INNER JOIN 	ewebUserDemographic ud ON ud.UserId = m.UserID
	INNER JOIN	ewebUserProfile up ON up.UserId = m.UserID
	INNER JOIN  vw_SC_UserList_AddedByUser adder ON adder.UserID = m.UserId
WHERE m.UserId NOT IN (SELECT     UserId
                       FROM          dbo.vw_SC_UserList_HasLoggedIn)
GO
