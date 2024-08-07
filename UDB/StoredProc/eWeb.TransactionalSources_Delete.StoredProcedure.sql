USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TransactionalSources_Delete]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[TransactionalSources_Delete]
       @AdministrationID int, 
	   @InputID int
AS
--Check parameter values
IF LTRIM(@AdministrationID) = '' OR LTRIM(@InputID) = '' 
BEGIN 
		RAISERROR ('Empty Parameter in @AdministrationID or @InputID for [TransactionalSources_Delete]', 1, 1);
		RETURN;
END



IF EXISTS(Select * From [Config].[TransactionalSources] Where [AdministrationID] = @AdministrationID and [InputID] = @InputID)
BEGIN

       Delete From [Config].[TransactionalSources]
       Where [AdministrationID] = @AdministrationID and [InputID] = @InputID
END
GO
