USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_Administration_InsertOrUpdate]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[eWeb_Administration_InsertOrUpdate]
	@AdminID                      int
	,@AdministrationName          varchar(100)
	,@StartDate                   DateTime
	,@EndDate                     DateTime
	,@UdbConnectionStringName     varchar(100)
	,@InteractiveReportDate       DateTime
	,@SeqNo                       int
	,@StateDbConnectionStringName varchar(100)
	,@IsParentAdministration      bit           = NULL
	,@ParentAdminID               int           = NULL
	,@StateCode                   varchar(2)    = NULL
AS

IF @IsParentAdministration IS NULL SET @IsParentAdministration = 0
IF @ParentAdminID IS NULL SET @ParentAdminID = @AdminID

/*Filter for n-dash and m-dash characters. Replace with regular dash.*/
Set @AdministrationName = Replace(Replace(@AdministrationName, nchar(8212), '-'), nchar(8211), '-')


IF EXISTS(Select * From [dbo].[eWebAdministration] Where AdministrationID = @AdminID)
BEGIN
	Update [dbo].[eWebAdministration]
	Set AdministrationName = @AdministrationName
		,StartDate = @StartDate
		,EndDate = @EndDate
		,UdbConnectionStringName = @UdbConnectionStringName
		,InteractiveReportDate = @InteractiveReportDate
		,SeqNo = @SeqNo
		,StateDbConnectionStringName = @StateDbConnectionStringName
		,IsParentAdministration = @IsParentAdministration
		,ParentAdministrationID = @ParentAdminID
		,StateCode = @StateCode
	Where AdministrationID = @AdminID
END
ELSE
BEGIN
	Insert Into [dbo].[eWebAdministration] (AdministrationID, AdministrationCode, AdministrationName, 
											StartDate, EndDate, UdbConnectionStringName, InteractiveReportDate, 
											SeqNo, StateDbConnectionStringName, IsParentAdministration,
											ParentAdministrationID, StateCode)
	Values (@AdminID, CAST(@AdminID AS varchar(10)), @AdministrationName, @StartDate, @EndDate, 
			@UdbConnectionStringName, @InteractiveReportDate, @SeqNo, @StateDbConnectionStringName, 
			@IsParentAdministration, @ParentAdminID, @StateCode)
END
GO
