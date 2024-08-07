USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteSiteSchedule]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [eWeb].[DeleteSiteSchedule]
@AdministrationID INT,
@TestWindow varchar(20), 
@DistrictCode varchar(15), 
@SchoolCode varchar(15)
AS
Begin

Declare @NewTestWindow varchar(20)
Declare @AssignmentLevel varchar(10)

Declare  @Sessions TABLE 
(
	AdministrationID Int, 
	TestSessionID Int, 
	[Test] varchar(50), 
	[Level] varchar(20), 
	[Mode] varchar(50)
)

If IsNull(@SchoolCode,'') = ''
Begin
	/* Find all Sessions for the District Assignment */
	Insert Into @Sessions
	Select s.AdministrationID,s.TestSessionID,s.[Test], s.[Level], s.[Mode]
	From Core.TestSession s
	Inner Join TestSession.Links k On k.AdministrationID=s.AdministrationID 
			And k.TestSessionID=s.TestSessionID
	Inner Join Document.TestTicketView x 
			On x.AdministrationID=s.AdministrationID 
			And x.DocumentID=k.DocumentID
	Where s.AdministrationID=@AdministrationID
	And s.DistrictCode =@DistrictCode
	And s.TestWindow=@TestWindow
	and s.ScheduleSource='District'
	Group by s.AdministrationID,s.TestSessionID,s.[Test], s.[Level], s.[Mode]
	Having count(x.DocumentID) = sum(case when x.Status = 'Not Started' then 1 else 0 end)

	
	
	/* Find the Default Testing Window */
	/* After the District Assignment is removed the Not Started Sessions will use the Defualt Testing Window*/
	Select @NewTestWindow= TestWindow
	From [Admin].TestWindow
	Where AdministrationID = @AdministrationID
	And IsDefault = 1

	Select @AssignmentLevel = 'Default'
End
Else
Begin  
 	/* Find all Sessions for the School Assignment */
	Insert Into @Sessions
	Select s.AdministrationID,s.TestSessionID,s.[Test], s.[Level], s.[Mode]
	From Core.TestSession s
	Inner Join TestSession.Links k On k.AdministrationID=s.AdministrationID 
			And k.TestSessionID=s.TestSessionID
	Inner Join Document.TestTicketView x 
			On x.AdministrationID=s.AdministrationID 
			And x.DocumentID=k.DocumentID
	Where s.AdministrationID=@AdministrationID
	And s.DistrictCode =@DistrictCode
	And s.SchoolCode = @SchoolCode
	and s.ScheduleSource='School'
	And s.TestWindow=@TestWindow
	Group by s.AdministrationID,s.TestSessionID,s.[Test], s.[Level], s.[Mode]
	Having count(x.DocumentID) = sum(case when x.Status = 'Not Started' then 1 else 0 end)
	
	/* Find a new Testing Window based on District Assignments or the Defualt Testing Window */
	/* After the School Assignement is removed the Not Started sessions will use the new Testing Window*/

	Select @NewTestWindow = TestWindow 
	From [Site].[TestWindows]
	Where AdministrationID = @AdministrationID
	And DistrictCode = @DistrictCode
	And IsNull(SchoolCode,'') = ''

	Select @AssignmentLevel = 'District'

	If @NewTestWindow is null
	Begin
		Select @NewTestWindow = TestWindow 
		From [Admin].[TestWindow]
		Where AdministrationID = @AdministrationID
		And IsDefault = 1

		Select @AssignmentLevel = 'Default'
	End
End

/* All sessions scheduled by previous assigned  are changed back the original assignment level*/
Update ts
Set ScheduleSource = @AssignmentLevel 
From Core.TestSession ts
Inner Join @Sessions as q1 
	On ts.AdminiStrationID = q1.AdministrationID 
	And ts.TestSessionID = q1.TestSessionID

/* All sessions scheduled by previous assigned  are linked back the original test window 
if the coresponding assessment schedules are exisitng */
Update ts
Set TestWindow = @NewTestWindow
From Core.TestSession ts
Inner Join @Sessions as q1 
	On ts.AdminiStrationID = q1.AdministrationID 
	And ts.TestSessionID = q1.TestSessionID
Inner Join [Admin].AssessmentSchedule a 
	On a.AdminiStrationID = q1.AdministrationID 
	And a.TestWindow = @NewTestWindow
	And a.[Test] = q1.[Test]
	And a.[Level] = q1.[Level]
	And a.Mode = q1.[Mode]

Update ts
Set StartTime = a.StartDate 
From Core.TestSession ts
Inner Join @Sessions as q1 
	On ts.AdminiStrationID = q1.AdministrationID 
	And ts.TestSessionID = q1.TestSessionID
Inner Join [Admin].AssessmentSchedule a 
	On a.AdminiStrationID = q1.AdministrationID 
	And a.TestWindow = @NewTestWindow
	And a.[Test] = q1.[Test]
	And a.[Level] = q1.[Level]
	And a.Mode = q1.[Mode]
Where StartTime < a.StartDate 
or StartTime > a.EndDate 

Update ts
Set EndTime = a.EndDate
From Core.TestSession ts
Inner Join @Sessions as q1 
	On ts.AdminiStrationID = q1.AdministrationID 
	And ts.TestSessionID = q1.TestSessionID
Inner Join [Admin].AssessmentSchedule a 
	On a.AdminiStrationID = q1.AdministrationID 
	And a.TestWindow = @NewTestWindow
	And a.[Test] = q1.[Test]
	And a.[Level] = q1.[Level]
	And a.Mode = q1.[Mode]
Where EndTime > a.EndDate 
or EndTime < a.StartDate    

/* Sync date range of Not Started sessions with the new testin window*/

DELETE FROM [Site].[TestWindows]
WHERE AdministrationID=@AdministrationID  
And TestWindow = @TestWindow
and DistrictCode = @DistrictCode
and isnull(SchoolCode,'') = isnull(@SchoolCode, '')

End
GO
