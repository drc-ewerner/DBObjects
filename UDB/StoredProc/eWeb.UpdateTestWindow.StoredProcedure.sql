USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateTestWindow]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [eWeb].[UpdateTestWindow]
@AdministrationID INT,
@TestWindow varchar(20),
@Description varchar(100),
@StartDate DateTime,
@EndDate DateTime,
@IsDefault bit,
@AllowSessionDateEdits bit
AS
Begin

Declare @IsDefaultOriginal tinyint

Select @IsDefaultOriginal = IsDefault
From [Admin].TestWindow
Where AdministrationID = @AdministrationID And TestWindow= @TestWindow

If @IsDefaultOriginal = 0 And @IsDefault = 1
Begin
	
	Create Table #Sessions (AdministrationID Int, TestSessionID Int, 
		[Test] varchar(50), [Level] varchar(20), [Mode] varchar(50))

	/*Get all 'Not Started' Test Sessions which testing windows were assigned by default */
	Insert Into #Sessions
	Select s.AdministrationID,s.TestSessionID,s.[Test], s.[Level], s.[Mode]
	From Core.TestSession s
	Inner Join TestSession.Links k On k.AdministrationID=s.AdministrationID 
			And k.TestSessionID=s.TestSessionID
	Inner Join Document.TestTicketView x 
			On x.AdministrationID=s.AdministrationID 
			And x.DocumentID=k.DocumentID
	Where s.AdministrationID=@AdministrationID
	and s.ScheduleSource='Default'
	Group by s.AdministrationID,s.TestSessionID,s.[Test], s.[Level], s.[Mode]
	Having count(x.DocumentID) = sum(case when x.Status = 'Not Started' then 1 else 0 end)
	
	/* If the cooresponding assessment schedule is available in the new default Testing Window 
	   then update the Test Session Schedule Link with the new defualt Testing Window and update test sessions
	   with the new begin date and end date */
	Update tss
	Set TestWindow = @TestWindow
	, ScheduleSource = 'Default'
	From Core.TestSession tss
	Inner join #Sessions as q1 
		On tss.AdminiStrationID = q1.AdministrationID 
		And tss.TestSessionID = q1.TestSessionID
	Inner Join [Admin].AssessmentSchedule  a 
		On a.AdminiStrationID = q1.AdministrationID 
		And a.TestWindow = @TestWindow
		And a.[Test] = q1.[Test]
		And a.[Level] = q1.[Level]
		And a.Mode = q1.[Mode]


	Update ts
	Set StartTime = a.StartDate , EndTime = a.EndDate
	From Core.TestSession ts
	Inner Join #Sessions as q2 
		On ts.AdminiStrationID = q2.AdministrationID 
		And ts.TestSessionID = q2.TestSessionID
	Inner Join [Admin].AssessmentSchedule a 
		On a.AdminiStrationID = q2.AdministrationID 
		And a.TestWindow = @TestWindow 
		And a.[Test] = q2.[Test]
		And a.[Level] = q2.[Level]
		And a.Mode = q2.[Mode]

End


UPDATE [Admin].TestWindow
   SET [Description] = @Description
      ,[StartDate] = @StartDate
      ,[EndDate] = @EndDate
      ,[IsDefault] = @IsDefault
      ,[AllowSessionDateEdits] = @AllowSessionDateEdits
 WHERE AdministrationID=@AdministrationID And TestWindow=@TestWindow
End
GO
