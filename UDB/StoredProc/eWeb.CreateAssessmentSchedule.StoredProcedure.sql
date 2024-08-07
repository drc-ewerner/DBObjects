USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[CreateAssessmentSchedule]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [eWeb].[CreateAssessmentSchedule]
@AdministrationID INT,
@TestWindow varchar(20),
@Test varchar(50),
@Level varchar(20),
@Mode varchar(50),
@StartDate DateTime,
@EndDate DateTime,
@CanReactivateTicket bit,
@AllowEdits bit
AS
Begin

Declare @Sessions Table
(
	AdministrationID Int, 
	TestSessionID Int, 
	Status varchar(50)
)

Declare @SiteSchedules TABLE
(
	AdministrationID Int, 
	DistrictCode varchar(10),
	SchoolCode varchar(10),
	TestWindow varchar(20)
)

INSERT INTO [Admin].[AssessmentSchedule]
           ([AdministrationID]
           ,[TestWindow]
           ,[Test]
           ,[Level]
           ,[Mode]
           ,[StartDate]
           ,[EndDate]
	   ,[AllowReactivates]
	   ,[AllowEdits])
     VALUES
           (@AdministrationID
           ,@TestWindow
           ,@Test
           ,@Level
           ,@Mode
           ,@StartDate
           ,@EndDate
	   ,@CanReactivateTicket
	   ,@AllowEdits)


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
inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
inner join Document.TestTicketView x on x.AdministrationID=s.AdministrationID and x.DocumentID=k.DocumentID
where s.AdministrationID=@AdministrationID
And s.TestWindow <> @TestWindow
And s.Test = @Test
And s.Level = @Level
And s.Mode = @Mode
group by s.AdministrationID,s.TestSessionID

INSERT INTO @SiteSchedules
SELECT AdministrationID
, DistrictCode
, SchoolCode
, TestWindow 
FROM [Site].[TestWindows]
WHERE AdministrationID = @AdministrationID
AND TestWindow = @TestWindow 

/*Update orphaned test sessions assigned at school level */

UPDATE ts
SET StartTime = @StartDate
FROM Core.TestSession ts
	INNER JOIN @Sessions s 
		ON s.AdministrationID = ts.AdministrationID
			AND s.TestSessionID = ts.TestSessionID
			And s.Status = 'Not Started'
	INNER JOIN @SiteSchedules st 
		ON st.AdministrationID = @AdministrationID 
			AND st.DistrictCode = ts.DistrictCode 
			AND st.SchoolCode = ts.SchoolCode 			
	INNER JOIN Admin.AssessmentSchedule a 
		ON a.AdministrationID = @AdministrationID 
			AND a.TestWindow = @TestWindow
			AND a.Test = ts.Test
			AND a.Level = ts.Level
			AND a.Mode = ts.Mode
WHERE ts.AdministrationID = @AdministrationID 
AND ts.TestWindow <> @TestWindow 
AND ( ts.StartTime < @StartDate
OR ts.StartTime > @EndDate)
	  
UPDATE ts
SET EndTime = @EndDate
FROM Core.TestSession ts
	INNER JOIN @Sessions s 
		ON s.AdministrationID = ts.AdministrationID
			AND s.TestSessionID = ts.TestSessionID
			And s.Status = 'Not Started'
	INNER JOIN @SiteSchedules st 
		ON st.AdministrationID = @AdministrationID 
			AND st.DistrictCode = ts.DistrictCode 
			AND st.SchoolCode = ts.SchoolCode 			
	INNER JOIN Admin.AssessmentSchedule a 
		ON a.AdministrationID = @AdministrationID 
			AND a.TestWindow = @TestWindow
			AND a.Test = ts.Test
			AND a.Level = ts.Level
			AND a.Mode = ts.Mode
WHERE ts.AdministrationID = @AdministrationID 
AND ts.TestWindow <> @TestWindow 
AND ( ts.EndTime > @EndDate
OR ts.EndTime < @StartDate)

UPDATE ts
SET TestWindow = @TestWindow
, ScheduleSource = 'School'
FROM Core.TestSession ts
	INNER JOIN @Sessions s 
		ON s.AdministrationID = ts.AdministrationID
			AND s.TestSessionID = ts.TestSessionID
			And s.Status = 'Not Started'
	INNER JOIN @SiteSchedules st 
		ON st.AdministrationID = @AdministrationID 
			AND st.DistrictCode = ts.DistrictCode 
			AND st.SchoolCode = ts.SchoolCode 			
	INNER JOIN Admin.AssessmentSchedule a 
		ON a.AdministrationID = @AdministrationID 
			AND a.TestWindow = @TestWindow
			AND a.Test = ts.Test
			AND a.Level = ts.Level
			AND a.Mode = ts.Mode
WHERE ts.AdministrationID = @AdministrationID 
AND ts.TestWindow <> @TestWindow 

				
/*Update orphaned test sessions assigned at district level */


UPDATE ts
SET StartTime = @StartDate
FROM Core.TestSession ts
	INNER JOIN @Sessions s 
		ON s.AdministrationID = ts.AdministrationID
			AND s.TestSessionID = ts.TestSessionID
			And s.Status = 'Not Started'
	INNER JOIN @SiteSchedules st 
		ON st.AdministrationID = @AdministrationID 
			AND st.DistrictCode = ts.DistrictCode 
			AND isnull(st.SchoolCode,'') = '' 			
	INNER JOIN Admin.AssessmentSchedule a 
		ON a.AdministrationID = @AdministrationID 
			AND a.TestWindow = @TestWindow
			AND a.Test = ts.Test
			AND a.Level = ts.Level
			AND a.Mode = ts.Mode
WHERE ts.AdministrationID = @AdministrationID 
AND ts.TestWindow <> @TestWindow 
AND ts.ScheduleSource <> 'School'
AND ( ts.StartTime < @StartDate
	  OR ts.StartTime > @EndDate)
	  
UPDATE ts
SET EndTime = @EndDate
FROM Core.TestSession ts
	INNER JOIN @Sessions s 
		ON s.AdministrationID = ts.AdministrationID
			AND s.TestSessionID = ts.TestSessionID
			And s.Status = 'Not Started'
	INNER JOIN @SiteSchedules st 
		ON st.AdministrationID = @AdministrationID 
			AND st.DistrictCode = ts.DistrictCode 
			AND isnull(st.SchoolCode,'') = '' 			
	INNER JOIN Admin.AssessmentSchedule a 
		ON a.AdministrationID = @AdministrationID 
			AND a.TestWindow = @TestWindow
			AND a.Test = ts.Test
			AND a.Level = ts.Level
			AND a.Mode = ts.Mode
WHERE ts.AdministrationID = @AdministrationID 
AND ts.TestWindow <> @TestWindow 
AND ts.ScheduleSource <> 'School'
AND ( ts.EndTime > @EndDate
	  OR ts.EndTime < @StartDate)

UPDATE ts
SET TestWindow = @TestWindow
, ScheduleSource = 'District'
FROM Core.TestSession ts
	INNER JOIN @Sessions s 
		ON s.AdministrationID = ts.AdministrationID
			AND s.TestSessionID = ts.TestSessionID
			And s.Status = 'Not Started'
	INNER JOIN @SiteSchedules st 
		ON st.AdministrationID = @AdministrationID 
			AND st.DistrictCode = ts.DistrictCode 
			AND isnull(st.SchoolCode,'') = ''
			 			
	INNER JOIN Admin.AssessmentSchedule a 
		ON a.AdministrationID = @AdministrationID 
			AND a.TestWindow = @TestWindow
			AND a.Test = ts.Test
			AND a.Level = ts.Level
			AND a.Mode = ts.Mode
WHERE ts.AdministrationID = @AdministrationID 
AND ts.TestWindow <> @TestWindow 
AND ts.ScheduleSource <> 'School'
	  
	  
IF EXISTS ( 
	SELECT 1 FROM Admin.TestWindow 
	Where AdministrationID = @AdministrationID 	  
	AND TestWindow = @TestWindow 
	AND IsDefault = 1)
BEGIN
	/*Update orphaned test sessions assigned at default level */

UPDATE ts
SET StartTime = @StartDate
FROM Core.TestSession ts
	INNER JOIN @Sessions s 
		ON s.AdministrationID = ts.AdministrationID
			AND s.TestSessionID = ts.TestSessionID
			And s.Status = 'Not Started'	 			
	INNER JOIN Admin.AssessmentSchedule a 
		ON a.AdministrationID = @AdministrationID 
			AND a.TestWindow = @TestWindow
			AND a.Test = ts.Test
			AND a.Level = ts.Level
			AND a.Mode = ts.Mode
WHERE ts.AdministrationID = @AdministrationID 
AND ts.TestWindow <> @TestWindow 
AND ts.ScheduleSource = 'Default'
AND ( ts.StartTime < @StartDate
OR ts.StartTime > @EndDate)
	  
UPDATE ts
SET EndTime = @EndDate
FROM Core.TestSession ts
	INNER JOIN @Sessions s 
		ON s.AdministrationID = ts.AdministrationID
			AND s.TestSessionID = ts.TestSessionID
			And s.Status = 'Not Started'		 			
	INNER JOIN Admin.AssessmentSchedule a 
		ON a.AdministrationID = @AdministrationID 
			AND a.TestWindow = @TestWindow
			AND a.Test = ts.Test
			AND a.Level = ts.Level
			AND a.Mode = ts.Mode
WHERE ts.AdministrationID = @AdministrationID 
AND ts.TestWindow <> @TestWindow 
AND ts.ScheduleSource = 'Default'
AND ( ts.EndTime > @EndDate
OR ts.EndTime < @StartDate)
END

UPDATE ts
SET TestWindow = @TestWindow
FROM Core.TestSession ts
	INNER JOIN @Sessions s 
		ON s.AdministrationID = ts.AdministrationID
			AND s.TestSessionID = ts.TestSessionID
			And s.Status = 'Not Started'		 			
	INNER JOIN Admin.AssessmentSchedule a 
		ON a.AdministrationID = @AdministrationID 
			AND a.TestWindow = @TestWindow
			AND a.Test = ts.Test
			AND a.Level = ts.Level
			AND a.Mode = ts.Mode
WHERE ts.AdministrationID = @AdministrationID 
AND ts.TestWindow <> @TestWindow 
AND ts.ScheduleSource = 'Default'

	  
End
GO
