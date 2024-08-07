USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTransactionalSources]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetTransactionalSources]
       @AdministrationId int
AS

select 
	 [AdministrationID]
	,[InputID]
	,[Source]
	,[Status] 
from config.TransactionalSources
where AdministrationID = @AdministrationId
GO
