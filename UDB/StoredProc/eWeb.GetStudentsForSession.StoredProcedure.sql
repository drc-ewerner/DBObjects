USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentsForSession]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetStudentsForSession]
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
as

/*==================================================================================
  01/16/13 - CLH: Changed Grade logic to remove conversion to int to support grade K
                 Not completely sure of all of the ramifications of doing this, so
				 only doing for SC at this point.
  11/14/14 - CSH: Sync this proc across all databases. This is the latest version, 
				as of today, with grade conversions to integers removed.
  03/16/15 - GL: Excluded students for test session if XRef.Grades.IsNotOnlineTesting = 'T' OR 
				(Student.Extensions.Name='HideStudentInEdirect' and Student.Extensions.Value='TestSessionAddition')

  ==================================================================================*/

set nocount on;set transaction isolation level read uncommitted;

declare @r table(AdministrationID int not null,StudentID int not null,LastName nvarchar(200),FirstName nvarchar(200),StateStudentID varchar(20), StudentGrade varchar(2), DistrictCode varchar(15), SchoolCode varchar(15));

select @StudentLastName=nullif(@StudentLastName,''),@StudentFirstName=nullif(@StudentFirstName,''),@StudentStateID=nullif(@StudentStateID,''),@Grade=nullif(@Grade,''),@Extension1Category=nullif(@Extension1Category,''),@Extension2Category=nullif(@Extension2Category,'');


insert @r (AdministrationID,StudentID,LastName,FirstName,StateStudentID,StudentGrade, DistrictCode, SchoolCode)
select distinct s.AdministrationID,s.StudentID,s.LastName,s.FirstName,s.StateStudentID,s.Grade,s.DistrictCode,s.SchoolCode
from Core.Student s
where
	s.AdministrationID = @AdministrationID and
	s.DistrictCode = @DistrictCode and
	s.SchoolCode = @SchoolCode and
	s.StateStudentID = isnull(@StudentStateID, s.StateStudentID) and
	s.LastName LIKE isnull(@StudentLastName, s.LastName) and
	s.FirstName LIKE isnull(@StudentFirstName, s.FirstName) and
	(isnull(@Grade, '') = '' or s.Grade = @Grade)


if (@Extension1Category is not null)
delete @r
from @r r
where not exists(select * from Student.Extensions x where x.AdministrationID=r.AdministrationID and x.StudentID=r.StudentID and x.Category=@Extension1Category and x.Name=@Extension1Name and x.Value=@Extension1Value);

if (@Extension2Category is not null)
delete @r
from @r r
where not exists(select * from Student.Extensions x where x.AdministrationID=r.AdministrationID and x.StudentID=r.StudentID and x.Category=@Extension2Category and x.Name=@Extension2Name and x.Value=@Extension2Value);

--exclude students for test session if the following conditions are satisfied
delete @r
from @r r
where (exists(select * from Student.Extensions x where x.AdministrationID=r.AdministrationID and x.StudentID=r.StudentID and x.Category='eWeb' and x.Name='HideStudentInEdirect' and x.Value='TestSessionAddition')
		OR exists(select * from XRef.Grades z where z.AdministrationID=r.AdministrationID and z.Grade =r.StudentGrade and ISNULL(z.IsNotOnlineTesting, 'F') = 'T'));

select 
	StudentID,LastName,FirstName,StateStudentID,
	AssessmentSessionCount = (
		select count(distinct ts.TestSessionID) 
		from Core.TestSession ts
		inner join TestSession.Links sl on ts.AdministrationID=sl.AdministrationID and ts.TestSessionID=sl.TestSessionID 
		where
		ts.AdministrationID = r.AdministrationID and
		ts.Test=@Test and
		ts.Level = @Level and
		sl.StudentID = r.StudentID),
	CurrentUserGroupCount=(
		select count(*) 
		from StudentGroup.Links k 
		inner join Teacher.StudentGroups g on g.AdministrationID=k.AdministrationID and g.GroupID=k.GroupID
		inner join Core.Teacher t on t.AdministrationID=k.AdministrationID and t.TeacherID=g.TeacherID
		where
		k.AdministrationID = r.AdministrationID and
		k.StudentID = r.StudentID and
		t.Email = @currentUserEmail),
		r.DistrictCode,
		r.SchoolCode 
from @r r
where (@filterByTestLevelGrades = 0) 
or 
not exists (select tlg.Grade from [Scoring].[TestLevelGrades] tlg where tlg.AdministrationID = r.AdministrationID and tlg.Test = @Test and tlg.Level = @Level)
or
(r.StudentGrade in (select tlg.Grade from [Scoring].[TestLevelGrades] tlg where tlg.AdministrationID = r.AdministrationID and (tlg.Test = @Test or tlg.Test = 'P_' + @Test) and LTRIM(RTRIM(tlg.Level)) = LTRIM(RTRIM(@Level))));
GO
