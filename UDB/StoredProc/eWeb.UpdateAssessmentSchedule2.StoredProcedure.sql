USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateAssessmentSchedule2]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[UpdateAssessmentSchedule2]
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

with q AS (

select 
	s.AdministrationID,s.TestSessionID
from Core.TestSession s
inner join [Admin].AssessmentSchedule a
	on a.AdministrationID = s.AdministrationID
	and a.TestWindow = s.TestWindow
	and a.Test = s.Test
	and a.[Level] = s.[Level]
	and a.EndDate = s.EndTime
	and a.Mode = s.Mode
inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
inner join Document.TestTicketView x on x.AdministrationID=s.AdministrationID and x.DocumentID=k.DocumentID
where 
	s.AdministrationID=@AdministrationID
	and a.TestWindow = @TestWindow
	and a.[Test] = @Test 
	and a.[Level] = @Level
	and a.Mode = @Mode
	group by s.AdministrationID,s.TestSessionID
	having max(x.Status) <> 'Completed'

)

Update Core.TestSession 
Set EndTime= @EndDate
From Core.TestSession ts
Inner join q on ts.AdministrationID = q.AdministrationID and ts.TestSessionID = q.TestSessionID


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
