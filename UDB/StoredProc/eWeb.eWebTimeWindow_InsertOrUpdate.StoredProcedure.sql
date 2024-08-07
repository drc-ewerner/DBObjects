USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[eWebTimeWindow_InsertOrUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[eWebTimeWindow_InsertOrUpdate]
       @AdministrationId int,
	   @AppletCode varchar(10), 
	   @Name  varchar(255),
	   @Permission varchar(255),
	   @StartDate datetime = null, 
	   @ReadOnlyDate  datetime = null, 
	   @EndDate datetime = null, 
	   
	   @LongDescription varchar(500) = null
AS
--Check parameter values
IF LTRIM(@permission) = '' OR LTRIM(@AppletCode) = '' OR LTRIM(@Name) = '' 
BEGIN 
		RAISERROR ('Empty Parameter in permission or AppletCode or Name for [eWebTimeWindow_InsertOrUpdate]', 1, 1);
		RETURN;
END

IF EXISTS(Select * From [eWeb].[TimeWindow] Where [AdministrationId]= @AdministrationId and [Descr] = @permission and [AppletCode] = @AppletCode and DisplayName = @Name)
BEGIN
       Update [eWeb].[TimeWindow]
       Set [StartDate] = @StartDate,
	   [EndDate] = @EndDate, 
	   [ReadOnlyDate] = @ReadOnlyDate,
	   [LongDescription] = @LongDescription
       Where [AdministrationId]= @AdministrationId and [Descr] = @permission and [AppletCode] = @AppletCode and DisplayName = @Name
END
ELSE
BEGIN
	   DECLARE @TimeWindowID  INT

	   SELECT @TimeWindowID=MAX(TimeWindowID) FROM eWeb.TimeWindow
	   IF @TimeWindowID is null 
			SELECT @TimeWindowID=0

	   INSERT INTO eWeb.TimeWindow
		(TimeWindowId, AdministrationId, Descr, AppletCode, StartDate, EndDate, ReadOnlyDate, DisplayName, LongDescription)
	   VALUES
		(@TimeWindowID + 1, @AdministrationId, @permission, @AppletCode, @StartDate, @EndDate, @ReadOnlyDate, @Name, @LongDescription)

END
GO
