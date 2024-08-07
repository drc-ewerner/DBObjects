USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveScheduleExtension]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[SaveScheduleExtension]
   @AdministrationID   int
   ,@Schedule   varchar(20)
   ,@RuleWeight int
   ,@Inclusion varchar(3)
   ,@RuleType varchar(20)
   ,@LowValue int
   ,@HighValue int
   
AS
BEGIN

	If Not Exists (
	
		Select * From Config.Schedule
		Where AdministrationID = @AdministrationID
		And Schedule =  @Schedule
		And RuleWeight = @RuleWeight 
		And Inclusion = @Inclusion
		And RuleType = @RuleType 
		And LowValue = @LowValue 
	)
	Insert Into Config.Schedule
	( 
		 AdministrationID
		,Schedule
		,RuleWeight
		,Inclusion
		,RuleType
		,LowValue
	,HighValue
   )
   Values (
		 @AdministrationID
		,@Schedule
		,@RuleWeight
		,@Inclusion
		,@RuleType
		,@LowValue
		,@HighValue
   )
END
GO
