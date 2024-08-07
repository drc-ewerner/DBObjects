USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_PurgeAdmin]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[eWeb_PurgeAdmin]
    @AdminID int
AS

	--together
	Delete From [dbo].[eWebPermissionSetScreen]
	Where PermissionSetId in (
		Select Distinct PermissionSetId
		From [dbo].[eWebPermissionSet]
		Where AdminID = @AdminID
	)
	Delete From [dbo].[eWebPermissionSet]
	Where AdminID = @AdminID

	--together
	Delete From [dbo].[eWebScreenAccess]
	Where ProfileId in (
		Select Distinct ProfileId 
		From [dbo].[eWebUserProfile]
		Where AdminId = @AdminID
	)
	Delete From [dbo].[eWebUserProfile]
	Where AdminId = @AdminID

	Delete From [dbo].[eWebAdminScreen]
	Where AdminId = @AdminID

	Delete From [dbo].[eWebAdministration]
	Where AdministrationID = @AdminID
GO
