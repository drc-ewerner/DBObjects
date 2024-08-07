USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[StrongMailMailing_InsertOrUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[StrongMailMailing_InsertOrUpdate]
       @StateCode varchar(4), @Environment varchar(20),
       @EmailType varchar(30), @MailingID varchar(30)
AS

IF LTRIM(ISNULL(@StateCode,'')) = '' OR LTRIM(ISNULL(@Environment,'')) = '' OR LTRIM(ISNULL(@EmailType,'')) = ''
BEGIN 
		RAISERROR ('Empty Parameter was passed for [eWeb].[StrongMailMailing_InsertOrUpdate]', 1, 1);
		RETURN;
END

IF EXISTS(Select * From [eWeb].[StrongMailMailing] Where StateCode = @StateCode and Environment = @Environment and EmailType = @EmailType)
BEGIN
       Update [eWeb].[StrongMailMailing]
       Set MailingID = @MailingID
       Where StateCode = @StateCode
	   and Environment = @Environment
	   and EmailType = @EmailType
END
ELSE
BEGIN
       Insert Into [eWeb].[StrongMailMailing] (StateCode, Environment, EmailType, MailingID)
       Values (@StateCode, @Environment, @EmailType, @MailingID)
END
GO
