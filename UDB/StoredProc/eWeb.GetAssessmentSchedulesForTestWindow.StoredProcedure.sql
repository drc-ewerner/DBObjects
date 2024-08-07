USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAssessmentSchedulesForTestWindow]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetAssessmentSchedulesForTestWindow]
@AdministrationID INT,
@TestWindow varchar(20)
AS
Begin
with DC_Assessment
as (
  select tsl.Test, tsl.Level, tsl.SubTest, tsl.SubLevel, tl.Description
  from Scoring.Tests t
  join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
  join Scoring.TestSessionSubTestLevels tsl On tl.AdministrationID = tsl.AdministrationID and tl.Level = tsl.Level and tl.Test = tsl.Test
  where t.AdministrationID = @AdministrationID
)
	Select a.TestWindow
	, a.Mode
	, t.ContentArea
	, a.Test
	, a.Level
	, AssessmentText=Case when max(dca.SubTest) is null then isnull(tl.[Description],tl.Level) else max(dca.description) + ' | ' + isnull(tl.[Description],tl.Level) end
	, a.StartDate
	, a.EndDate
	, CAST(a.AllowReactivates AS BIT) AS AllowReactivates
	, CAST(a.AllowEdits AS BIT) AS AllowEdits
	, HasAssociatedSessions = Cast( case when sum(case when ts.AdministrationID is null then 0 else 1 end) > 0 then 1 else 0 end AS BIT)
	From [Admin].AssessmentSchedule a 
	INNER join [Admin].TestWindow tss on tss.AdministrationID = a.AdministrationID 
		And tss.TestWindow = a.TestWindow
	INNER Join Scoring.Tests t ON a.AdministrationID = t.AdministrationID and a.Test = t.Test
	INNER join Scoring.TestLevels tl ON a.AdministrationID = tl.AdministrationID and a.Test = tl.Test and a.Level = tl.Level
	left join DC_Assessment dca on a.Test = dca.SubTest and a.Level = dca.SubLevel
	left join Core.TestSession ts on ts.AdministrationID = tss.AdministrationID 
		and ts.TestWindow=a.TestWindow and ts.[Test] = a.[Test] And ts.[Level] = a.[Level] and ts.[Mode]=a.Mode
	Where a.AdministrationID = @AdministrationID 
	And a.TestWindow = @TestWindow
	group by 
	 a.TestWindow
	, a.Mode
	, t.ContentArea
	, a.Test
	, a.Level
	, isnull(tl.[Description],tl.Level)
	, a.StartDate
	, a.EndDate
	, a.AllowReactivates
	, a.AllowEdits
End
GO
