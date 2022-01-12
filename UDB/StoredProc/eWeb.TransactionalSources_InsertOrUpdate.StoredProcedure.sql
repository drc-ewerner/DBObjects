USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TransactionalSources_InsertOrUpdate]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[TransactionalSources_InsertOrUpdate]
       @AdministrationID int, 
	   @InputID int, 
	   @Source varchar(20),
	   @Status varchar(30)
AS
--Check parameter values
IF LTRIM(@Source) = '' OR LTRIM(@Status) = '' 
BEGIN 
		RAISERROR ('Empty Parameter in Source or Status for [TransactionalSources_InsertOrUpdate]', 1, 1);
		RETURN;
END



IF EXISTS(Select * From [Config].[TransactionalSources] Where [AdministrationID] = @AdministrationID and InputID = @InputID)
BEGIN
       Update [Config].[TransactionalSources]
       Set [Source] = @Source, [Status] = @Status
       Where [AdministrationID] = @AdministrationID and InputID = @InputID
END
ELSE
BEGIN
       Insert Into [Config].[TransactionalSources] ([AdministrationID], [InputID], [Source], [Status])
       Values (@AdministrationID, @InputID, @Source, @Status)
END
GO
