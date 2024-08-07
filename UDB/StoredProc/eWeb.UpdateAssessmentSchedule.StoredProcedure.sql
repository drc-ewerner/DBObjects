USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateAssessmentSchedule]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [eWeb].[UpdateAssessmentSchedule]
@AdministrationID INT,
@TestWindow varchar(20),
@Test varchar(50),
@Level varchar(20),
@Mode varchar(50),
@StartDate DateTime,
@EndDate DateTime,
@AllowReactivates bit,
@AllowEdits bit
AS
Begin

Declare @Sessions Table 
(
	AdministrationID Int, 
	TestSessionID Int, 
	[Status] varchar(20)
)


Insert Into @Sessions
select 
s.AdministrationID
,s.TestSessionID
,Status = case 	
		when count(x.DocumentID) = sum(case when x.Status = 'Not Started' then 1 else 0 end) then 'Not Started'
		when count(x.DocumentID) = sum(case when x.Status = 'Submitted' then 1 else 0 end) then 'Submitted'
		when count(x.DocumentID) = sum(case when x.Status = 'Completed' then 1 else 0 end) then 'Completed'
		when count(x.DocumentID)  =sum(case when x.Status = 'Submitted' or x.Status = 'Completed' then 1 else 0 end)   then 'Submitted'
	  else 
		'In Progress' 
	  end
from Core.TestSession s
inner join Scoring.Tests AS tes ON s.AdministrationID = tes.AdministrationID and s.Test = tes.test
inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
inner join Document.TestTicketView x on x.AdministrationID=s.AdministrationID and x.DocumentID=k.DocumentID
where s.AdministrationID=@AdministrationID
And s.TestWindow = @TestWindow
And s.Test = @Test
And s.Level = @Level
And s.Mode = @Mode
group by s.AdministrationID,s.TestSessionID


Update Core.TestSession 
Set StartTime= @StartDate
From Core.TestSession ts
Inner Join @Sessions s On s.AdministrationID = ts.AdministrationID And s.TestSessionID = ts.TestSessionID
Where ts.AdministrationID = @AdministrationID 
and ts.TestWindow  = @TestWindow 
and ts.Test = @Test
and ts.Level = @Level
and ts.Mode = @Mode
and ( ts.StartTime < @StartDate
or ts.StartTime > @EndDate )	
and s.Status = 'Not Started'


Update Core.TestSession 
Set EndTime= @EndDate
From Core.TestSession ts
Inner Join @Sessions s On s.AdministrationID = ts.AdministrationID And s.TestSessionID = ts.TestSessionID
Where ts.AdministrationID = @AdministrationID 
and ts.TestWindow  = @TestWindow 
and ts.Test = @Test
and ts.Level = @Level
and ts.Mode = @Mode
and ( ts.EndTime > @EndDate 
or ts.EndTime < @StartDate)	
and (s.Status = 'Not Started'
or s.Status = 'In Progress'
)

UPDATE [Admin].[AssessmentSchedule]
   SET [StartDate] = @StartDate
      ,[EndDate] = @EndDate
      ,[AllowReactivates] = @AllowReactivates
      ,[AllowEdits] = @AllowEdits
 WHERE AdministrationID=@AdministrationID  
 And TestWindow=@TestWindow
 and Test=@Test
 and [Level]=@Level
 and [Mode]=@Mode
End
GO
