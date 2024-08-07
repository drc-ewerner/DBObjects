USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_GetBasicUserPermsByUserId]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[eWeb_GetBasicUserPermsByUserId]
(
	 @UserId   uniqueidentifier
)
AS

/*
******************************************************************************************************
* dbo.eWeb_GetBasicUserPermsByUserId                                                                 *
******************************************************************************************************
* Return a distinct list of active basic permissions for a user.                                     *
*                                                                                                    *
* LOGIC:                                                                                             *
*    - See LOGIC section of dbo.vw_GetBasicUserPerms                                                 *
*    - Filter the results of that view by UserId                                                     *
******************************************************************************************************
*/

BEGIN

  SELECT UserId
        ,Username
		,Email
		,ACE
  FROM dbo.vw_GetBasicUserPerms
  WHERE UserId = @UserId

END
GO
