USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[vw_GetBasicUserPerms]    Script Date: 7/2/2024 9:45:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vw_GetBasicUserPerms]

AS

/*
******************************************************************************************************
* dbo.vw_GetBasicUserPerms                                                                           *
******************************************************************************************************
* Return a view of each user's basic active permissions.                                             *
*                                                                                                    *
* LOGIC:                                                                                             *
*    - Distinct list of all ScreenCode values the user has across all Active Administrations (i.e.   *
*      if the user has a permission/ScreenCode in more than one active Administration, there should  *
*      be only one record per permission/ScreenCode)                                                 *
*    - Active administrations only                                                                   *
*    - If User account is Inactive, then return no records                                           *
*    - New Security Component ACE Example: SC:edirect-legacy-materials-ui:view                       *
*      (this view will return these like "edirect-legacy-materials-ui:view" and the "client code"    *
*      needs to be prepended by the caller)                                                          *
*	 - If the user has "superuser" for any admin, give all permissions/ACLs							 *
******************************************************************************************************
*/

SELECT DISTINCT
     m.UserId                      AS UserId
	,u.UserName                    AS Username
	,m.Email                       AS Email
	,eca.PermissionTopNavECA       AS ACE
FROM aspnet_Membership  m
JOIN aspnet_Users       u   ON  m.UserId         = u.UserId
JOIN eWebUserProfile    p   ON  m.UserId         = p.UserId
JOIN eWebAdministration a   ON  p.AdminId        = a.AdministrationID
JOIN eWebScreenAccess   sa  ON  p.ProfileId      = sa.ProfileId
JOIN eWebScreen         s   ON  sa.PermissionID  = s.PermissionID
JOIN eWebMapPermToECA   eca ON  (s.ScreenCode     = eca.ScreenCode OR s.ScreenCode = 'Superuser')
WHERE m.IsApproved = 1  /* User account is Active */
 AND  (a.EndDate IS NULL OR a.EndDate >= GETDATE())  /* Active admnistrations */
 AND  (a.StartDate IS NULL OR a.StartDate <= GETDATE())  /* Active admnistrations */
GO
