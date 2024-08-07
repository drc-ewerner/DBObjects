USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveConfigExtension]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[SaveConfigExtension] 
   @AdministrationID int
   ,@Category varchar(50)
   ,@Name varchar(50)
   ,@Value varchar(1000)
AS

BEGIN
	Delete from [Config].[Extensions] 
	Where AdministrationID = @AdministrationID 
	and Category = @Category 
	and [Name] = @Name
	
	Insert Into [Config].[Extensions]
    ([AdministrationID]
    ,[Category]
    ,[Name]
    ,[Value])
	Values
    (@AdministrationID
    ,@Category
    ,@Name
    ,@Value)

END
GO
