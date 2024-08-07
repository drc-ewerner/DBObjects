USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ConfigExtensionNames_InsertOrUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[ConfigExtensionNames_InsertOrUpdate]
        @Category varchar(50),
		@Name varchar(200),
		@eDirectProject varchar(200),
		@ControlName varchar(100),
		@SortOrder Integer
AS
--Check parameter values
IF (LTRIM(@Category) = '' OR LTRIM(@Name) = '' OR LTRIM(@eDirectProject) = '' OR LTRIM(@ControlName) = '' OR ISNULL(@SortOrder, '') = '')
BEGIN 
		RAISERROR ('Empty Parameter was supplied for [eWeb].[ConfigExtensionNames_InsertOrUpdate]', 1, 1);
		RETURN;
END

IF NOT EXISTS(Select * From [eWeb].[ConfigExtensionNames] Where Category = @Category And Name = @Name and eDirectProject = @eDirectProject)
BEGIN

	INSERT INTO [eWeb].[ConfigExtensionNames] (Category, Name, eDirectProject, ControlName, SortOrder)
	Values (@Category, @Name, @eDirectProject, @ControlName, @SortOrder)
			
END

Return (Select [NamesID] From [eWeb].[ConfigExtensionNames] Where Category = @Category And Name = @Name and eDirectProject = @eDirectProject)
GO
