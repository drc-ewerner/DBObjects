USE [Alaska_udb_dev]
GO
/****** Object:  View [eWeb].[StudentDetail]    Script Date: 1/12/2022 1:31:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [eWeb].[StudentDetail] as 
select distinct
	s.AdministrationID,
	s.StudentID,
	s.Grade, 
	s.LastName,
	s.FirstName,
	s.DistrictStudentID,
	s.StateStudentID,	
	sext.Value as SSN,
	s.DistrictCode,
	dist.SiteName AS DistrictName, 
	s.SchoolCode, 
	sch.SiteName AS SchoolName
from Core.Student s
inner join Core.Site dist on dist.AdministrationID=s.AdministrationID and dist.SiteCode=s.DistrictCode
inner join Core.Site sch on sch.AdministrationID=s.AdministrationID and sch.SiteCode=s.SchoolCode and sch.SuperSiteCode=s.DistrictCode
left join Student.Extensions sext on s.StudentID = sext.StudentID and s.AdministrationID = sext.AdministrationID 
	and sext.Name = 'SSN'
GO
