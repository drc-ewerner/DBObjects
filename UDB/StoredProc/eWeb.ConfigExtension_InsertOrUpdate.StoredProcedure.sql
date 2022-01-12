USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ConfigExtension_InsertOrUpdate]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[ConfigExtension_InsertOrUpdate]
       @AdminID int, @Category varchar(50),
       @Name varchar(200), @Value varchar(1500)
AS
--Check parameter values
IF LTRIM(@Name) = '' OR LTRIM(@Category) = '' 
BEGIN 
		RAISERROR ('Empty Parameter in name or category for [ConfigExtension_InsertOrUpdate]', 1, 1);
		RETURN;
END

IF EXISTS(Select * From [Config].[Extensions] Where AdministrationID = @AdminID and Category = @Category and Name = @Name)
BEGIN
       Update [Config].[Extensions]
       Set Value = @Value
       Where AdministrationID = @AdminID
       and Category = @Category
       and Name = @Name
END
ELSE
BEGIN
       Insert Into [Config].[Extensions] (AdministrationID, Category, Name, Value)
       Values (@AdminID, @Category, @Name, @Value)
END

GO
