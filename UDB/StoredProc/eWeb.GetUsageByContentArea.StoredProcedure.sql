USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetUsageByContentArea]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[GetUsageByContentArea]
	@pAdminID integer, 
	@pDistrictCode as varchar(15),
	@pSchoolCode as varchar(15),
	@pCountyCode as varchar(255),
	@pIUCode as varchar(255)
AS
BEGIN

set nocount on;
set transaction isolation level read uncommitted;


/*This conversion is needed for now because eDirect LINQ 
	TO SQL is currently mapped to <'p' + name>.*/
Declare @AdminID as integer, 
	@DistrictCode as varchar(15) = '' ,
	@SchoolCode as varchar(15),
	@CountyCode as varchar(255) ,
	@IUCode as varchar(255) 

Set @AdminID = @pAdminID
Set	@DistrictCode = @pDistrictCode
Set @SchoolCode = @pSchoolCode
Set	@CountyCode = @pCountyCode
Set	@IUCode = @pIUCode



select distinct ContentArea
into #ContentArea
from Scoring.Tests 
where AdministrationID=@AdminID and ContentArea is not null and ContentArea not like '$%'
and not exists(select * from Config.Extensions ext where AdministrationID=@AdminID and Category='eWeb' and Name=ContentArea + '.Hide' and Value='Y')
 
select distinct D.AdministrationID, D.SiteCode As DistrictCode, 
CASE WHEN D.SiteSubType in('04', '39') OR schl.SiteID is null THEN 0 ELSE 1 END As IsSchoolDistrict,
C.AttributeValue As CountyCode, IU.AttributeValue As IUCode
into #DistAttribute
from Core.Site D
left join Core.Site schl on schl.AdministrationID=D.AdministrationID and schl.SuperSiteID=D.SiteID and schl.SiteSubType <> '03'
Left JOIN Site.Attributes C ON C.SiteID = D.SiteID and C.AdministrationID = D.AdministrationID 
  and C.AttributeName = 'County' 
Left JOIN Site.Attributes IU ON IU.SiteID = D.SiteID and IU.AdministrationID = D.AdministrationID 
  and IU.AttributeName = 'IUCode' 
where D.AdministrationID = @AdminID and D.SiteType = 'District' 

select w.AdministrationID,st.ContentArea,DistrictCount=count(distinct s.DistrictCode)
into #DistCount
from TestSession.Links k
inner join Document.TestTicket t on t.AdministrationID=k.AdministrationID and t.DocumentID=k.DocumentID
inner join Core.TestEvent e on e.AdministrationID=k.AdministrationID and e.DocumentID=k.DocumentID
inner join Core.TestSession w on w.AdministrationID=k.AdministrationID and w.TestSessionID=k.TestSessionID
left join eWeb.UsageReportSitesToBeExcluded  excl on w.AdministrationID=excl.AdministrationID and w.DistrictCode=excl.DistrictCode and w.SchoolCode=excl.SchoolCode
inner join Scoring.Tests st on w.AdministrationID=st.AdministrationID and w.Test=st.Test 
inner join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
inner join Core.Student s on s.AdministrationID=k.AdministrationID and s.StudentID=k.StudentID and s.Grade in ('06','07','08','09','10','11','12','HS')
inner join Core.Site i on i.AdministrationID = s.AdministrationID and i.SiteCode = s.SchoolCode and i.SuperSiteCode=s.DistrictCode
inner Join #DistAttribute a on s.DistrictCode = a.DistrictCode and a.IsSchoolDistrict=1
where k.AdministrationID=@AdminID 
       and (CountyCode = @CountyCode Or @CountyCode = '')
       and (IUCode = @IUCode Or @IUCode = '')
       and (s.DistrictCode = @DistrictCode or @DistrictCode = '')
       and (s.SchoolCode = @SchoolCode or @SchoolCode = '')
       and excl.AdministrationID is null
group by w.AdministrationID,st.ContentArea

select w.AdministrationID,st.ContentArea,SchoolCount=count(distinct s.SchoolCode),StudentCount=count(distinct k.StudentID)
into #NonDistCount
from TestSession.Links k
inner join Document.TestTicket t on t.AdministrationID=k.AdministrationID and t.DocumentID=k.DocumentID
inner join Core.TestEvent e on e.AdministrationID=k.AdministrationID and e.DocumentID=k.DocumentID
inner join Core.TestSession w on w.AdministrationID=k.AdministrationID and w.TestSessionID=k.TestSessionID
left join eWeb.UsageReportSitesToBeExcluded  excl on w.AdministrationID=excl.AdministrationID and w.DistrictCode=excl.DistrictCode and w.SchoolCode=excl.SchoolCode
inner join Scoring.Tests st on w.AdministrationID=st.AdministrationID and w.Test=st.Test 
inner join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
inner join Core.Student s on s.AdministrationID=k.AdministrationID and s.StudentID=k.StudentID and s.Grade in ('06','07','08','09','10','11','12','HS')
inner join Core.Site i on i.AdministrationID = s.AdministrationID and i.SiteCode = s.SchoolCode and i.SuperSiteCode=s.DistrictCode
inner Join #DistAttribute a on s.DistrictCode = a.DistrictCode 
where k.AdministrationID=@AdminID 
       and (CountyCode = @CountyCode Or @CountyCode = '')
       and (IUCode = @IUCode Or @IUCode = '')
       and (s.DistrictCode = @DistrictCode or @DistrictCode = '')
       and (s.SchoolCode = @SchoolCode or @SchoolCode = '')
       and excl.AdministrationID is null
group by w.AdministrationID,st.ContentArea


select C.ContentArea, isnull(DistrictCount, 0) As DistrictCount,
isnull(SchoolCount, 0) As SchoolCount, isnull(StudentCount, 0) As StudentCount
From #ContentArea C
Left JOIN #DistCount ON C.ContentArea =	#DistCount.ContentArea 
Left JOIN #NonDistCount ON C.ContentArea =	#NonDistCount.ContentArea 
Order by C.ContentArea

drop table #DistCount
drop table #DistAttribute
drop table #NonDistCount
drop table #ContentArea
END
GO
