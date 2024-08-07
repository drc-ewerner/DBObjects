USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TransactionalSources_InsertOrUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
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
