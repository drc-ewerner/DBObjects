USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetScheduleExtensions]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[GetScheduleExtensions]
   @AdministrationID   int
   ,@Schedule   varchar(20)
   
AS
BEGIN
	Select 
	Schedule,
	RuleWeight,
	Inclusion,
	RuleType,
	LowValue,
	HighValue
	From Config.Schedule
	Where AdministrationID = @AdministrationID
	And Schedule = @Schedule
END
GO
