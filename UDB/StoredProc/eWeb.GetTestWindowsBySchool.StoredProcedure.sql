USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestWindowsBySchool]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [eWeb].[GetTestWindowsBySchool]
	@AdministrationID int
As

Declare @AdminName varchar(100)
Declare @Defaultwindow varchar(100)

Select @AdminName=LongDescription + ' ' + coalesce(Season,'') +  ' '  + coalesce([Year],'')
from Core.Administration where AdministrationId=@AdministrationID;

Select @Defaultwindow=[Description] from  [Admin].TestWindow where AdministrationId= @AdministrationId and
	IsDefault = 1

Select distinct @AdminName AdminName,di.SiteCode DistrictCode,di.SiteName DistrictName,
sc.SiteCode SchoolCode,sc.SiteName SchoolName,
case 
	when coalesce(schTest.TestWindow, '') = '' and coalesce(disTest.TestWindow, '') = '' then @Defaultwindow
	when coalesce(schTest.TestWindow, '') = '' and coalesce( disTest.TestWindow, '') <> '' then disTest.Description
	when coalesce(schTest.TestWindow, '') <> '' then schTest.Description
End WindowName
,
case 
	when coalesce(schTest.TestWindow, '') = '' and coalesce(disTest.TestWindow, '') = '' then 'Default'
	when coalesce(schTest.TestWindow, '') = '' and coalesce(disTest.TestWindow, '') <> '' then 'District'
	when coalesce(schTest.TestWindow, '') <> '' then 'School'
End level_assigned_at
From 
(SELECT * FROM [Core].[Site] where sitetype = 'School') sc inner join 
(SELECT * FROM [Core].[Site] where sitetype = 'District') di 
 on sc.AdministrationId = di.AdministrationID and sc.SuperSiteID =di.SiteID and sc.AdministrationId = @AdministrationId left outer join
(
	SELECT ss.AdministrationID,ss.TestWindow, ss.DistrictCode, ss.SchoolCode,ts.Description
	FROM [Site].TestWindows ss inner join
	[Admin].TestWindow ts on ss.AdministrationID = ts.AdministrationId and ss.TestWindow = ts.TestWindow
	WHERE ss.AdministrationID = @AdministrationID
	AND isnull(SchoolCode,'') <> ''
	
) schTest on sc.AdministrationID = schTest.AdministrationID and sc.SiteCode=schTest.SchoolCode 
and sc.SuperSiteCode=schTest.Districtcode left outer join
(
		SELECT ss.AdministrationID,ss.TestWindow, ss.DistrictCode,ts.Description
	FROM [Site].TestWindows ss inner join
	[Admin].TestWindow ts on ss.AdministrationID = ts.AdministrationId and ss.TestWindow = ts.TestWindow
	WHERE ss.AdministrationID = @AdministrationID
	AND isnull(ss.SchoolCode,'') = ''
) disTest on di.AdministrationID = disTest.AdministrationID and di.SiteCode=disTest.DistrictCode
GO
