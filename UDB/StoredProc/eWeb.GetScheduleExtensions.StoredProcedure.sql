USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetScheduleExtensions]    Script Date: 7/2/2024 9:21:54 AM ******/
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
