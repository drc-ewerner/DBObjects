USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAssessmentScheduleForSession]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetAssessmentScheduleForSession]
@AdministrationID INT,
@TestSessionID INT
AS
Begin

	Select ts.TestWindow
	, ts.Description
	, ts.StartDate
	, ts.EndDate
	, CAST(ts.IsDefault AS BIT) as IsDefault
	, CAST(ts.AllowSessionDateEdits AS BIT) AS AllowSessionDateEdits
	, a.Mode
	, t.ContentArea
	, a.Test
	, a.Level
	, AssessmentText=isnull(tl.[Description],tl.Level)
	, AssessmentScheduleStartDate = a.StartDate
	, AssessmentScheduleEndDate = a.EndDate
	, CAST(a.AllowReactivates AS BIT) as AllowReactivates
	, CAST(a.AllowEdits AS BIT) as AllowEdits
	, tl.OptionalProcessing
	From Core.TestSession q
	INNER JOIN [Admin].TestWindow ts ON ts.AdministrationID=q.AdministrationID
		AND ts.TestWindow = q.TestWindow
	Inner Join [Admin].AssessmentSchedule a On ts.AdministrationID = a.AdministrationID 
		and q.TestWindow=a.TestWindow and q.Test=a.Test and q.[Level]=a.[Level] and q.[Mode]=a.Mode
	Inner Join Scoring.Tests t ON a.AdministrationID = t.AdministrationID and a.Test = t.Test
	inner join Scoring.TestLevels tl ON a.AdministrationID = tl.AdministrationID and a.Test = tl.Test and a.Level = tl.Level 
	Where q.AdministrationID = @AdministrationID 
	And q.TestSessionID = @TestSessionID
End
GO
