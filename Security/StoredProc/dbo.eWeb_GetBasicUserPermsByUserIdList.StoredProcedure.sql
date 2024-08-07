USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_GetBasicUserPermsByUserIdList]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_GetBasicUserPermsByUserIdList](@UserIds XML) AS
/*
******************************************************************************************************
* dbo.eWeb_GetBasicUserPermsByUserIdList                                                                 *
******************************************************************************************************
* Return a distinct list of active basic permissions for a user.                                     *
*                                                                                                    *
* LOGIC:                                                                                             *
*    - See LOGIC section of dbo.vw_GetBasicUserPerms                                                 *
*    - Filter the results of that view by UserId                                                     *
******************************************************************************************************
*/

BEGIN
	DECLARE @uids TABLE(UserId UNIQUEIDENTIFIER PRIMARY KEY CLUSTERED(UserId))

	INSERT INTO @uids
	SELECT Tbl.Col.value('.', 'UNIQUEIDENTIFIER') AS UserId
	FROM @UserIds.nodes('//ArrayOfGuid/guid') Tbl(Col)

	SELECT  bp.UserId
		, bp.Username
		, bp.Email
		, bp.ACE
	FROM dbo.vw_GetBasicUserPerms bp
	INNER JOIN @uids uids ON uids.UserId = bp.UserId

END
GO
