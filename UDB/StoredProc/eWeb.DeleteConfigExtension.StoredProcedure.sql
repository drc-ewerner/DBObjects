USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteConfigExtension]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[DeleteConfigExtension] 
   @AdministrationID int
   ,@Category varchar(50)
   ,@Name varchar(50)
AS

BEGIN
	Delete from [Config].[Extensions] 
	Where AdministrationID = @AdministrationID 
	and Category = @Category 
	and [Name] = @Name

END
GO
