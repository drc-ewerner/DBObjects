USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TransactionalSources_Delete]    Script Date: 1/12/2022 1:30:39 PM ******/
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
