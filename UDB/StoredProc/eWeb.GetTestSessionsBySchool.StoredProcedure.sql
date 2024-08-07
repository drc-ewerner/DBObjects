USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestSessionsBySchool]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE procedure [eWeb].[GetTestSessionsBySchool]
	@AdministrationID	int,
	@DistrictCode		varchar(15),
	@SchoolCode			varchar(15)
as
select 
	Name=max(s.Name)
	,s.TestSessionID
	,ContentArea=max(isnull(t.ContentArea,t.Test))
	,Test=max(s.Test)
	,Level=max(tl.Level)
	,AssessmentText=max(isnull(tl.Description,tl.Level))
	,Status=case when min(x.Status)='Not Started' then 'Not Started' when max(x.Status)='Completed' then 'Completed' else 'In Progress' end
	,s.StartTime
	,s.EndTime,
	s.DistrictCode
	,s.SchoolCode
	,dist.SiteName DistrictName
	,sch.SiteName schoolName
	,s.Mode
	,StudentCountInCurrentUserGroup=null
	,TotalStudentCount=count(*)
from Core.TestSession s
inner join Core.Site dist on s.AdministrationID=dist.AdministrationID and s.DistrictCode= dist.SiteCode and dist.SuperSiteCode='DEPTOFED'
inner join Core.Site sch on s.AdministrationID = sch.AdministrationID and s.DistrictCode=sch.SuperSiteCode and s.SchoolCode=sch.SiteCode
inner join Scoring.Tests t on t.AdministrationID=s.AdministrationID and t.Test=s.Test
inner join Scoring.TestLevels tl on tl.AdministrationID=s.AdministrationID and tl.Test=s.Test and tl.Level=s.Level
inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
inner join Document.TestTicketView x on x.AdministrationID=s.AdministrationID and x.DocumentID=k.DocumentID
where s.AdministrationID=@AdministrationID and dist.SiteCode = @DistrictCode AND sch.SiteCode = @SchoolCode
group by s.AdministrationID,s.TestSessionID,s.StartTime,s.EndTime,s.DistrictCode,s.SchoolCode,dist.SiteName,sch.SiteName,s.Mode
GO
