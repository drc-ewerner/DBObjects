USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_RemovePermFromPermSet]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_RemovePermFromPermSet]
	(@AdminID INT, @PermissionSetName NVARCHAR(50), @ScreenCode VARCHAR(100)) AS
BEGIN

DELETE eWebPermissionSetScreen
FROM eWebPermissionSetScreen pss
INNER JOIN eWebPermissionSet ps ON ps.PermissionSetID = pss.PermissionSetID
INNER JOIN eWebScreen sc ON sc.PermissionID = pss.PermissionID
WHERE ps.AdminID = @AdminID AND ps.PermissionSetName = @PermissionSetName
	AND sc.ScreenCode = @ScreenCode

END
GO
