USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ConfigExtension_Delete]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[ConfigExtension_Delete]
   @AdminID int, 
   @Category varchar(50),
   @Name varchar(200)
AS

--Check parameter values
IF LTRIM(@Name) = '' OR LTRIM(@Category) = '' 
BEGIN 
		RAISERROR ('Empty Parameter in name or category for [ConfigExtension_Delete]', 1, 1);
		RETURN;
END

IF EXISTS(Select * From [Config].[Extensions] Where AdministrationID = @AdminID and Category = @Category and Name = @Name)
BEGIN
	Delete from [Config].[Extensions] 
	Where AdministrationID = @AdminID 
	and Category = @Category 
	and [Name] = @Name
END
GO
