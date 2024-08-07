USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[CreateSiteSchedule]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [eWeb].[CreateSiteSchedule]
@AdministrationID INT,
@TestWindow varchar(20),
@DistrictCode varchar(15),
@SchoolCode varchar(15)
AS
Begin

Declare @AssignedWindow varchar(20)
Declare @Sessions TABLE
(
	AdministrationID Int, 
	TestSessionID Int, 
	[Test] varchar(50), 
	[Level] varchar(20), 
	[Mode] varchar(50)
)


/* District Assignment */
If IsNull(@SchoolCode,'') = ''
Begin
	Select @AssignedWindow = TestWindow From  [Site].TestWindows
	Where AdministrationID = @AdministrationID
	And DistrictCode = @DistrictCode
	And IsNull(SchoolCode,'')  = ''

	if @AssignedWindow is not null
		exec [eWeb].[DeleteSiteSchedule] @AdministrationID, @AssignedWindow, @DistrictCode, @SchoolCode


	/*For the given district get all  Test Sessions  which testing windows were assigned by default or district */
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
	and s.ScheduleSource != 'School'
	Group by s.AdministrationID,s.TestSessionID,s.[Test], s.[Level], s.[Mode]
	Having count(x.DocumentID) = sum(case when x.Status = 'Not Started' then 1 else 0 end)
	
	/* If the cooresponding assessment schedule is available in the newly assigned Testing Window 
	   then update the Test Session Schedule Link with the newly assigned Testing Window. */ 
	Update ts
	Set TestWindow = @TestWindow
	, ScheduleSource = 'District'
	From Core.TestSession ts
	Inner Join @Sessions as q1 
		On ts.AdminiStrationID = q1.AdministrationID 
		And ts.TestSessionID = q1.TestSessionID
	Inner Join [Admin].[AssessmentSchedule] a 
		On a.AdminiStrationID = q1.AdministrationID 
		And a.TestWindow = @TestWindow 
		And a.[Test] = q1.[Test]
		And a.[Level] = q1.[Level]
		And a.Mode = q1.[Mode]

End	
Else
/* School Assignment */
Begin
	
	Select @AssignedWindow = TestWindow From  [Site].TestWindows
	Where AdministrationID = @AdministrationID
	And DistrictCode = @DistrictCode
	And SchoolCode = @SchoolCode

	
	if @AssignedWindow is not null
		exec [eWeb].[DeleteSiteSchedule] @AdministrationID, @AssignedWindow, @DistrictCode, @SchoolCode

	

	/*For the given school get all Test Sessions  which testing windows were assigned by default, district or school */
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
	Group by s.AdministrationID,s.TestSessionID,s.[Test], s.[Level], s.[Mode]
	Having count(x.DocumentID) = sum(case when x.Status = 'Not Started' then 1 else 0 end)
	
	
	/* If the cooresponding assessment schedule is available in the newly assigned Testing Window 
	   then update the Test Session Schedule Link with the newly assigned Testing Window. */
	Update ts
	Set TestWindow = @TestWindow
	, ScheduleSource = 'School'
	From Core.TestSession ts
	Inner Join @Sessions as q1 On ts.AdminiStrationID = q1.AdministrationID 
		And ts.TestSessionID = q1.TestSessionID
	Inner Join [Admin].[AssessmentSchedule] a 
	On a.AdminiStrationID = q1.AdministrationID 
	And a.TestWindow = @TestWindow
	And a.[Test] = q1.[Test]
	And a.[Level] = q1.[Level]
	And a.Mode = q1.[Mode]

End

/* If the cooresponding assessment schedule is available in the newly assigned Testing Window then update test sessionswith the new begin date and end date */
Update Core.TestSession
Set StartTime = a.StartDate 
From Core.TestSession ts
Inner Join @Sessions as q2 
	On ts.AdminiStrationID = q2.AdministrationID 
	And ts.TestSessionID = q2.TestSessionID
Inner Join [Admin].[AssessmentSchedule] a 
	On a.AdminiStrationID = q2.AdministrationID 
	And a.TestWindow = @TestWindow
	And a.[Test] = q2.[Test]
	And a.[Level] = q2.[Level]
	And a.Mode = q2.[Mode]
Where StartTime < a.StartDate 
or StartTime > a.EndDate 

Update Core.TestSession
Set EndTime = a.EndDate
From Core.TestSession ts
Inner Join @Sessions as q2 
	On ts.AdminiStrationID = q2.AdministrationID 
	And ts.TestSessionID = q2.TestSessionID
Inner Join [Admin].[AssessmentSchedule] a 
	On a.AdminiStrationID = q2.AdministrationID 
	And a.TestWindow = @TestWindow
	And a.[Test] = q2.[Test]
	And a.[Level] = q2.[Level]
	And a.Mode = q2.[Mode]
Where EndTime > a.EndDate 
or EndTime < a.StartDate 

Insert Into [Site].[TestWindows]
           ([AdministrationID]
           ,[TestWindow]
           ,[DistrictCode]
           ,[SchoolCode]
           )
Values
           (@AdministrationID
           ,@TestWindow
           ,@DistrictCode
           ,isnull(@SchoolCode, '')
           )

End
GO
