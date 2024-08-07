USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentsForSessionNTeacher]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetStudentsForSessionNTeacher]
@AdministrationID int,
@DistrictCode varchar(15),
@SchoolCode varchar(15),
@Test varchar(50),
@Level varchar(20),
@TestSessionID int,
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
@filterByTestLevelGrades bit = 0 
AS
BEGIN

set nocount on;set transaction isolation level read uncommitted;

declare @r table(AdministrationID int not null,StudentID int not null,LastName nvarchar(200),FirstName nvarchar(200),StateStudentID varchar(20), StudentGrade varchar(2), DistrictCode varchar(15), SchoolCode varchar(15));

select @StudentLastName=nullif(@StudentLastName,''),@StudentFirstName=nullif(@StudentFirstName,''),@StudentStateID=nullif(@StudentStateID,''),@Grade=nullif(@Grade,''),@Extension1Category=nullif(@Extension1Category,''),@Extension2Category=nullif(@Extension2Category,'');

if ((@StudentStateID is not null) and (rtrim(@StudentStateID) <> ''))
begin

       insert @r (AdministrationID,StudentID,LastName,FirstName,StateStudentID,StudentGrade, DistrictCode, SchoolCode)
       select distinct s.AdministrationID,s.StudentID,s.LastName,s.FirstName,s.StateStudentID,s.Grade,s.DistrictCode,s.SchoolCode
       from Core.Student s
       where
              s.StateStudentID = isnull(@StudentStateID, s.StateStudentID) and s.AdministrationID = @AdministrationID
              
end 
else
begin

       insert @r (AdministrationID,StudentID,LastName,FirstName,StateStudentID,StudentGrade, DistrictCode, SchoolCode)
       select distinct s.AdministrationID,s.StudentID,s.LastName,s.FirstName,s.StateStudentID,s.Grade,s.DistrictCode,s.SchoolCode
       from Core.Student s
       where
              s.AdministrationID = @AdministrationID and
              s.DistrictCode = @DistrictCode and   
              s.SchoolCode = @SchoolCode and
              s.LastName LIKE isnull(@StudentLastName, s.LastName) and
              s.FirstName LIKE isnull(@StudentFirstName, s.FirstName) and
			  s.StateStudentID=isnull(@StudentStateID,s.StateStudentID) and 
              s.Grade = isnull(@Grade, s.Grade)

end;


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
              DistrictCode,
              SchoolCode 
from @r r
where (@filterByTestLevelGrades = 0) 
or 
 not exists (select tlg.Grade from [Scoring].[TestLevelGrades] tlg where tlg.AdministrationID = r.AdministrationID and tlg.Test = @Test and tlg.Level = @Level)
or
(r.StudentGrade in (select tlg.Grade from [Scoring].[TestLevelGrades] tlg where tlg.AdministrationID = r.AdministrationID and tlg.Test = @Test and tlg.Level = @Level));

END


GO
