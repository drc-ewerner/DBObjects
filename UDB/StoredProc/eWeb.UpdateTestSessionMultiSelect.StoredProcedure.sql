USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateTestSessionMultiSelect]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[UpdateTestSessionMultiSelect]
		@AdministrationID INT, 
		@TestSessionID INT, 
		@StartTime DATETIME, 
		@EndTime DATETIME, 
		@Name VARCHAR (100), 
		@teacherID int,
		@ClassCode varchar(15) = '',
		@ScoringOption VARCHAR(50) = NULL,
		@TestMonitoring AS VARCHAR(50) = NULL,
		@TestAccess AS VARCHAR(10) = NULL
	AS
	BEGIN

	update Core.TestSession 
	set
		StartTime=@StartTime,
		EndTime=@EndTime,
		Name=@Name, 
		TeacherID=case when @teacherID=0 then null else @teacherID end,
		ClassCode = @ClassCode,
		ScoringOption = CASE WHEN @ScoringOption IS NOT NULL AND @ScoringOption <> '' THEN @ScoringOption ELSE NULL END,
		UpdateDate=getdate(),
		TestMonitoring = NULLIF(@TestMonitoring, ''),
		TestAccessControl = NULLIF(@TestAccess, '')
	where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID

	END
GO
