USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentsForSessionPA]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[GetStudentsForSessionPA]
@AdministrationID int,
@DistrictCode varchar(15),
@SchoolCode varchar(15),
@Test varchar(50),
@Level varchar(20),
@TestSessionID int,
@TeacherID int,
@GroupID int,
@Grade varchar(2),
@StudentLastName varchar(100),
@StudentFirstName varchar(100),
@StudentStateID varchar(20),
@Extension1Category varchar(50),
@Extension1Name varchar(50),
@Extension1Value varchar(100),
@Extension2Category varchar(50),
@Extension2Name varchar(50),
@Extension2Value varchar(100),
@currentUserEmail varchar(256) = null,
@filterByTestLevelGrades bit = 0 
WITH RECOMPILE
as

set nocount on;
set transaction isolation level read uncommitted;

DECLARE @lAdministrationID int;
DECLARE @lDistrictCode varchar(15);
DECLARE @lSchoolCode varchar(15);
DECLARE @lTest varchar(50);
DECLARE @lLevel varchar(20);
DECLARE @lTestSessionID int;
DECLARE @lTeacherID int;
DECLARE @lGroupID int;
DECLARE @lGrade varchar(2);
DECLARE @lStudentLastName varchar(100);
DECLARE @lStudentFirstName varchar(100);
DECLARE @lStudentStateID varchar(20);
DECLARE @lExtension1Category varchar(50);
DECLARE @lExtension1Name varchar(50);
DECLARE @lExtension1Value varchar(100);
DECLARE @lExtension2Category varchar(50);
DECLARE @lExtension2Name varchar(50);
DECLARE @lExtension2Value varchar(100);
DECLARE @lcurrentUserEmail varchar(256);
DECLARE @lfilterByTestLevelGrades bit;
DECLARE @IsShowAlternateTestingSites bit = 0		
SELECT @IsShowAlternateTestingSites=case when eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','ConfigUI.ShowAlternateTestingSites','N')='Y' then 1 else 0 end
--Testing Only set @IsShowAlternateTestingSites = 1	

SET @lAdministrationID = @AdministrationID;
SET @lDistrictCode = @DistrictCode;
SET @lSchoolCode = @SchoolCode;
SET @lTest = @Test;
SET @lLevel = @Level;
SET @lTestSessionID = @TestSessionID;
SET @lTeacherID = @TeacherID;
SET @lGroupID = @GroupID;
SET @lGrade = @Grade;
SET @lStudentLastName = @StudentLastName;
SET @lStudentFirstName = @StudentFirstName;
SET @lStudentStateID = @StudentStateID;
SET @lExtension1Category = @Extension1Category;
SET @lExtension1Name = @Extension1Name;
SET @lExtension1Value = @Extension1Value;
SET @lExtension2Category = @Extension2Category;
SET @lExtension2Name = @Extension2Name;
SET @lExtension2Value = @Extension2Value;
SET @lcurrentUserEmail = @currentUserEmail;
SET @lfilterByTestLevelGrades = @filterByTestLevelGrades;

CREATE TABLE #r (AdministrationID int not null,StudentID int not null,LastName nvarchar(200),FirstName nvarchar(200),BirthDate DateTime null,StateStudentID varchar(20), StudentGrade varchar(2), DistrictCode varchar(15), SchoolCode varchar(15));

declare @assessmentTest varchar(50)
declare @assessmentLevel varchar(20)
select @assessmentTest = tsl.Test, @assessmentLevel = tsl.Level
from Scoring.Tests t
join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
join Scoring.TestSessionSubTestLevels tsl On tl.AdministrationID = tsl.AdministrationID and tl.Level = tsl.Level and tl.Test = tsl.Test
where tsl.SubTest = @lTest
  and tsl.SubLevel = @lLevel
if @assessmentTest IS NULL set @assessmentTest = @lTest
if @assessmentLevel IS NULL set @assessmentLevel = @lLevel

select 
	@lStudentLastName=nullif(@lStudentLastName,''),
	@lStudentFirstName=nullif(@lStudentFirstName,''),
	@lStudentStateID=nullif(@lStudentStateID,''),
	@lGrade=nullif(@lGrade,''),
	@lExtension1Category=nullif(@lExtension1Category,''),
	@lExtension2Category=nullif(@lExtension2Category,'');

if ((@lStudentStateID is not null) and (rtrim(@lStudentStateID) <> ''))
begin

       insert #r (AdministrationID,StudentID,LastName,FirstName,StateStudentID,StudentGrade, DistrictCode, SchoolCode)
       select distinct s.AdministrationID,s.StudentID,s.LastName,s.FirstName,s.StateStudentID,s.Grade,s.DistrictCode,s.SchoolCode
       from Core.Student s
       where
              s.StateStudentID = isnull(@lStudentStateID, s.StateStudentID) and s.AdministrationID = @lAdministrationID
			  and ( -- ED-4679, ED-7781
					      (( @IsShowAlternateTestingSites = 0 and
					        s.DistrictCode = isnull(@DistrictCode, s.DistrictCode) and
						    s.SchoolCode =  isnull(@SchoolCode,s.SchoolCode) 
						   ) OR 
						   ( @IsShowAlternateTestingSites = 1  
						   ))
						   )
end 
else if ((@lTeacherID = -1) and (@lGroupID = 0)) 
begin

       insert #r (AdministrationID,StudentID,LastName,FirstName,BirthDate,StateStudentID,StudentGrade, DistrictCode, SchoolCode)
       select distinct s.AdministrationID,s.StudentID,s.LastName,s.FirstName,s.BirthDate,s.StateStudentID,s.Grade,s.DistrictCode,s.SchoolCode
       from Core.Student s
       where
              s.AdministrationID = @lAdministrationID and
              s.DistrictCode = @lDistrictCode and   
              s.SchoolCode = @lSchoolCode and
					      (( @IsShowAlternateTestingSites = 0 and
					        s.DistrictCode = isnull(@DistrictCode, s.DistrictCode) and
						    s.SchoolCode = isnull(@SchoolCode, s.SchoolCode) 
						   ) OR 
						   ( @IsShowAlternateTestingSites = 1  
						   )) and
              s.LastName LIKE isnull(@lStudentLastName, s.LastName) and
              s.FirstName LIKE isnull(@lStudentFirstName, s.FirstName) and
              s.Grade = isnull(@lGrade, s.Grade)

end 
else if (@lGroupID = 0) 
begin

       insert #r (AdministrationID,StudentID,LastName,FirstName,BirthDate,StateStudentID,StudentGrade, DistrictCode, SchoolCode)
       select distinct s.AdministrationID,s.StudentID,s.LastName,s.FirstName,s.BirthDate,s.StateStudentID,s.Grade,s.DistrictCode,s.SchoolCode
       from Core.Student s
       inner join StudentGroup.Links k on k.AdministrationID=s.AdministrationID and k.StudentID=s.StudentID
       inner join Teacher.StudentGroups tg on tg.AdministrationID=s.AdministrationID and tg.GroupID=k.GroupID
       where 
              s.AdministrationID=@lAdministrationID and 
              tg.TeacherID=@lTeacherID and 
              s.LastName=isnull(@lStudentLastName,s.LastName) and 
              s.FirstName=isnull(@lStudentFirstName,s.FirstName) and 
					   -- ED-4679, ED-7781
					      (( @IsShowAlternateTestingSites = 0 and
					        s.DistrictCode = isnull(@DistrictCode, s.DistrictCode) and
						    s.SchoolCode =  isnull(@SchoolCode,s.SchoolCode) 
						   ) OR 
						   ( @IsShowAlternateTestingSites = 1  
						   )) and
              s.StateStudentID=isnull(@lStudentStateID,s.StateStudentID) and 
              s.Grade=isnull(@lGrade,s.Grade)

end 
else 
begin

       insert #r (AdministrationID,StudentID,LastName,FirstName,BirthDate,StateStudentID,StudentGrade, DistrictCode, SchoolCode)
       select distinct s.AdministrationID,s.StudentID,s.LastName,s.FirstName,s.BirthDate,s.StateStudentID,s.Grade,s.DistrictCode,s.SchoolCode
       from Core.Student s
       inner join StudentGroup.Links k on k.AdministrationID=s.AdministrationID and k.StudentID=s.StudentID
       inner join Teacher.StudentGroups tg on tg.AdministrationID=s.AdministrationID and tg.GroupID=k.GroupID
       where 
              s.AdministrationID=@lAdministrationID and 
					   -- ED-4679, ED-7781
					      (( @IsShowAlternateTestingSites = 0 and
					        s.DistrictCode = isnull(@DistrictCode, s.DistrictCode) and
						    s.SchoolCode =  isnull(@SchoolCode,s.SchoolCode) 
						   ) OR 
						   ( @IsShowAlternateTestingSites = 1  
						   )) and
              tg.GroupID=@lGroupID and 
              tg.TeacherID=@lTeacherID and 
              s.LastName=isnull(@lStudentLastName,s.LastName) and 
              s.FirstName=isnull(@lStudentFirstName,s.FirstName) and 
              s.StateStudentID=isnull(@lStudentStateID,s.StateStudentID) and 
              s.Grade=isnull(@lGrade,s.Grade)

end;

CREATE INDEX ix_r_AdministrationID ON #r (AdministrationID);
CREATE INDEX ix_r_StudentID ON #r (StudentID);
CREATE INDEX ix_r_StudentGrade ON #r (StudentGrade);


if (@lExtension1Category is not null)
delete #r
from #r r
where not exists(select * from Student.Extensions x where x.AdministrationID=r.AdministrationID and x.StudentID=r.StudentID and x.Category=@lExtension1Category and x.Name=@lExtension1Name and x.Value=@lExtension1Value);

if (@lExtension2Category is not null)
delete #r
from #r r
where not exists(select * from Student.Extensions x where x.AdministrationID=r.AdministrationID and x.StudentID=r.StudentID and x.Category=@lExtension2Category and x.Name=@lExtension2Name and x.Value=@lExtension2Value);

--exclude students for test session if the following conditions are satisfied
delete #r
from #r r
where (exists(select * from Student.Extensions x where x.AdministrationID=r.AdministrationID and x.StudentID=r.StudentID and x.Category='eWeb' and x.Name='HideStudentInEdirect' and x.Value='TestSessionAddition')
		OR exists(select * from XRef.Grades z where z.AdministrationID=r.AdministrationID and z.Grade =r.StudentGrade and ISNULL(z.IsNotOnlineTesting, 'F') = 'T'));


select 
       StudentID,LastName,FirstName,BirthDate,StateStudentID,
       AssessmentSessionCount = (
              select count(distinct ts.TestSessionID) 
              from Core.TestSession ts
              inner join TestSession.Links sl on ts.AdministrationID=sl.AdministrationID and ts.TestSessionID=sl.TestSessionID 
              where
              ts.AdministrationID = r.AdministrationID and
              ts.Test=@lTest and
              ts.Level = @lLevel and
              sl.StudentID = r.StudentID),
       CurrentUserGroupCount=(
              select count(*) 
              from StudentGroup.Links k 
              inner join Teacher.StudentGroups g on g.AdministrationID=k.AdministrationID and g.GroupID=k.GroupID
              inner join Core.Teacher t on t.AdministrationID=k.AdministrationID and t.TeacherID=g.TeacherID
              where
              k.AdministrationID = r.AdministrationID and
              k.StudentID = r.StudentID and
              t.Email = @lcurrentUserEmail),
              DistrictCode,
              SchoolCode 
from #r r
where (@lfilterByTestLevelGrades = 0) 
or 
 not exists (select tlg.Grade from [Scoring].[TestLevelGrades] tlg where tlg.AdministrationID = r.AdministrationID and tlg.Test = @assessmentTest and tlg.Level = @assessmentLevel)
or
(r.StudentGrade in (select tlg.Grade from [Scoring].[TestLevelGrades] tlg where tlg.AdministrationID = r.AdministrationID and tlg.Test = @assessmentTest and tlg.Level = @assessmentLevel));

DROP TABLE #r;
GO
