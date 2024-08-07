USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestSessionById]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [eWeb].[GetTestSessionById]
@AdministrationID int,
@TestSessionID int,
@CurrentUserEmail varchar(256) = null
as
begin

/* 09/05/2010 - Version 1.0 */ 
/* 06/14/2013 - Changed To Accommodate South Carolina */
/* 01/11/2024 - Updated To Accommodate TerraNova */

with q as (
	select distinct tg.AdministrationID,t.Email,k.StudentID
	from Teacher.StudentGroups tg
	inner join Core.Teacher t on t.AdministrationID=tg.AdministrationID and t.TeacherID=tg.TeacherID
	inner join StudentGroup.Links k on k.AdministrationID=tg.AdministrationID and k.GroupID=tg.GroupID	
),
DC_Assessment
as (
  select tsl.Test, tsl.Level, tsl.SubTest, tsl.SubLevel, tl.Description
  from Scoring.Tests t
  join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
  join Scoring.TestSessionSubTestLevels tsl On tl.AdministrationID = tsl.AdministrationID and tl.Level = tsl.Level and tl.Test = tsl.Test
  where t.AdministrationID = @AdministrationID
),
DC_Assessment2 AS (
  SELECT t.AdministrationID, tsl.Test, tsl.[Level], tsl.SubTest, tsl.SubLevel, tl.[Description], stl.TestSessionID
	FROM Scoring.Tests t
	JOIN Scoring.TestLevels tl ON tl.AdministrationID=t.AdministrationID AND tl.Test=t.Test
	JOIN Scoring.TestSessionSubTestLevels tsl ON tl.AdministrationID = tsl.AdministrationID AND tl.Level = tsl.SubLevel AND tl.Test = tsl.SubTest
	JOIN TestSession.SubTestLevels stl ON tl.AdministrationID = stl.AdministrationID AND tl.Level = stl.SubLevel AND tl.Test = stl.SubTest
	JOIN Config.Extensions x ON x.AdministrationID = @AdministrationID AND x.Category = 'eWeb' AND x.Name = 'TestTickets.UseAssessmentForSubTest' AND x.Value = 'Y' 
	WHERE t.AdministrationID = @AdministrationID
	AND stl.TestSessionID = @TestSessionID
)
select 
	Name=max(s.Name),s.TestSessionID,ContentArea=max(isnull(t.ContentArea,t.Test)),Test=max(isnull(dca.Test, s.Test)),Level=max(isnull(dca.Level, tl.Level)),SubTest=max(isnull(dca.SubTest, '')),SubLevel=max(isnull(dca.SubLevel, '')),AssessmentText=max(coalesce(dca2.Description,dca.Description,tl.Description,tl.Level)), DiagnosticCategoryText=case when max(dca.Description) is null then '' else max(isnull(tl.Description, tl.Level)) end,
	Status=case when min(x.Status)='Not Started' then 'Not Started' when max(x.Status)='Completed' then 'Completed' else 'In Progress' end,
	s.StartTime,s.EndTime,s.DistrictCode,s.SchoolCode, s.Mode,s.ClassCode, cs1.sitename as schoolName, cs2.sitename as DistrictName, 
	t2.FirstName as TeacherFirstName, t2.LastName as TeacherLastName,
	StudentCountInCurrentUserGroup=count(q.StudentID),
	TotalStudentCount=count(*)
from Core.TestSession s
inner join Scoring.Tests t on t.AdministrationID=s.AdministrationID and t.Test=s.Test
inner join Scoring.TestLevels tl on tl.AdministrationID=s.AdministrationID and tl.Test=s.Test and tl.Level=s.Level
left join DC_Assessment dca on tl.Test = dca.SubTest and tl.Level = dca.SubLevel
inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
inner join Document.TestTicketView x on x.AdministrationID=s.AdministrationID and x.DocumentID=k.DocumentID
left join q on q.AdministrationID=s.AdministrationID and q.StudentID=k.StudentID and q.Email=@CurrentUserEmail
inner join Core.Site cs1 on cs1.AdministrationID = s.AdministrationID and cs1.SiteType = 'School' and cs1.SiteCode = s.SchoolCode and cs1.SuperSiteCode = s.DistrictCode 
inner join Core.Site cs2 on cs2.AdministrationID = s.AdministrationID and cs2.SiteType = 'District' and cs2.SiteCode = s.DistrictCode 
left join Core.Teacher t2 on t2.AdministrationID=s.AdministrationID and t2.TeacherID=s.TeacherID
left join DC_Assessment2 dca2 ON s.AdministrationID = dca2.AdministrationID AND s.TestSessionID = dca2.TestSessionID
where s.AdministrationID=@AdministrationID and s.TestSessionID=@TestSessionID
group by s.AdministrationID,s.TestSessionID,s.StartTime,s.EndTime,s.DistrictCode,s.SchoolCode,s.Mode, s.ClassCode, cs1.SiteName, cs2.SiteName, t2.FirstName, t2.LastName
end
GO
