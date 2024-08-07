USE [Alaska_udb_dev]
GO
/****** Object:  View [eWeb].[StudentLookup_Basic]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [eWeb].[StudentLookup_Basic] as 
select distinct
	s.AdministrationID,
	s.StudentID,
	s.Grade, 
	s.LastName,
	s.FirstName,
	s.MiddleName,
	BubbledLastName = s.LastName, 
	BubbledFirstName = s.FirstName, 
	BubbledMiddleName = s.MiddleName,
	s.DistrictStudentID,
	s.StateStudentID,	
	SSN = null,
	BatchNumber = '',
	SerialNumber = '',
	LithoCode = '', 
	s.DistrictCode,
	s.SchoolCode,
	sch.SiteName as SchoolName,
	CourseName = '', 
	SecurityCode = '' 
from Core.Student s
inner join Core.Site sch on sch.AdministrationID=s.AdministrationID and sch.SiteCode=s.SchoolCode and sch.SuperSiteCode=s.DistrictCode
GO
