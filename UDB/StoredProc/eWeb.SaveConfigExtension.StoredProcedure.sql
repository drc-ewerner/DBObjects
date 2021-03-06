USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveConfigExtension]    Script Date: 1/12/2022 1:30:39 PM ******/
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
