USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_MassFindUserIDByEmail]    Script Date: 1/12/2022 2:05:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[eWeb_MassFindUserIDByEmail]
	@UsersByEmail VARCHAR(4000)

AS
BEGIN
	SELECT  m.UserId, 
			m.LoweredEmail,
			m.IsApproved
    FROM	dbo.aspnet_Membership m  
	INNER JOIN dbo.Split(LOWER(@UsersByEmail), ',')  e ON m.LoweredEmail = e.items

END
GO
