USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[MailingMapping_InsertOrUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	CREATE PROCEDURE [eWeb].[MailingMapping_InsertOrUpdate]
		   @StateCode varchar(4),
		   @Environment varchar(30),
		   @EmailType varchar(30), 
		   @TemplateID varchar(50)
	AS

	IF LTRIM(ISNULL(@StateCode,'')) = '' OR LTRIM(ISNULL(@Environment,'')) = '' OR LTRIM(ISNULL(@EmailType,'')) = ''
	BEGIN 
			RAISERROR ('Empty Parameter was passed for [eWeb].[MailingMapping_InsertOrUpdate]', 1, 1);
			RETURN;
	END

	IF EXISTS(Select * From [eWeb].[MailingMapping] Where StateCode = @StateCode and Environment = @Environment and EmailType = @EmailType)
	BEGIN
		   Update [eWeb].[MailingMapping]
		   Set TemplateID = @TemplateID
		   Where StateCode = @StateCode
		   and Environment = @Environment
		   and EmailType = @EmailType
	END
	ELSE
	BEGIN
		   Insert Into [eWeb].[MailingMapping] (StateCode, Environment, EmailType, TemplateID)
		   Values (@StateCode, @Environment, @EmailType, @TemplateID)
	END
	
GO
