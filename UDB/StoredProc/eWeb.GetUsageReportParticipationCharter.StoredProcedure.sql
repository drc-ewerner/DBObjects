USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetUsageReportParticipationCharter]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [eWeb].[GetUsageReportParticipationCharter]
	@pAdministrationID as integer, 
	@pDistrictCode as varchar(15) = '' ,
	@pCountyCode as varchar(255) ,
	@pIUCode as varchar(255) 
As

set nocount on;
set transaction isolation level read uncommitted;


/*This conversion is needed for now because eDirect LINQ 
	TO SQL is currently mapped to <'p' + name>.*/
Declare @AdministrationID as integer, 
	@DistrictCode as varchar(15) = '' ,
	@CountyCode as varchar(255) ,
	@IUCode as varchar(255) 

Set @AdministrationID = @pAdministrationID
Set	@DistrictCode = @pDistrictCode
Set	@CountyCode = @pCountyCode
Set	@IUCode = @pIUCode


if @DistrictCode <> '' 
Begin
	select 'Charter School' SiteType, isnull(sum(pct.Participating),0)Participating,COUNT(*) - isnull(sum(pct.Participating),0) NotParticipating, Count(*) Total  
	from core.site os inner join Core.Site d on d.AdministrationID=os.AdministrationID and d.SiteCode=os.SuperSiteCode and d.SiteType = 'district'
	left join eWeb.UsageReportSitesToBeExcluded excl on  os.SiteCode=excl.schoolcode and d.SiteCode=excl.districtcode and excl.administrationid=d.AdministrationID
	Left JOIN Site.Attributes C ON C.SiteID = d.SiteID and C.AdministrationID = d.AdministrationID 
		  and C.AttributeName = 'County' and C.AttributeValue <> ''
		Left JOIN Site.Attributes IU ON IU.SiteID = d.SiteID and IU.AdministrationID = d.AdministrationID 
		  and IU.AttributeName = 'IUCode'  and IU.AttributeValue <> ''
	outer apply
	(
	select  sess.AdministrationID,sess.districtcode,
	case when sum(case when tk.Status='Completed' then 1 else 0 end) > 0 then 1 else 0 end Participating 
	 from 
	Document.TestTicketView tk 
	inner join TestSession.Links ls on tk.AdministrationID=ls.AdministrationID and tk.DocumentID=ls.DocumentID 
	inner join Core.Student stud on stud.AdministrationID=ls.AdministrationID and stud.StudentID=ls.StudentID and stud.Grade in ('06','07','08','09','10','11','12','HS')
	inner join Scoring.TestForms tf on tk.AdministrationID=tf.AdministrationID and tk.Test=tf.Test and tk.Level=tf.Level and tk.Form=tf.Form and tf.Format='CAT'
	inner join Core.TestSession sess on sess.AdministrationID=ls.AdministrationID and sess.TestSessionID=ls.TestSessionID
	where sess.SchoolCode=os.SiteCode
	and not sess.SchoolCode in (select schoolcode from eWeb.UsageReportSitesToBeExcluded where districtcode = sess.DistrictCode and schoolcode = sess.SchoolCode)
	group by sess.AdministrationID,sess.DistrictCode,sess.SchoolCode
	having sess.AdministrationID=os.AdministrationID and sess.DistrictCode=os.SuperSiteCode 
	) pct
	where os.AdministrationID=@AdministrationId  and  os.SiteType='School' 
	and d.SiteSubType='04'
	and (C.AttributeValue=@CountyCode or @CountyCode='') and (iu.AttributeValue=@IUCode or @IUCode='')
	and os.SuperSiteCode=@DistrictCode and excl.AdministrationID is null
End	
Else
Begin
	select 'Charter School' SiteType, isnull(sum(pct.Participating),0) Participating,COUNT(*) - isnull(sum(pct.Participating),0) NotParticipating, isnull(Count(*),0) Total  
	from core.site os inner join Core.Site ds on ds.AdministrationID= os.AdministrationID and ds.SiteCode=os.SuperSiteCode and ds.siteType = 'district'
	left join eWeb.UsageReportSitesToBeExcluded excl on  os.SiteCode=excl.schoolcode and ds.SiteCode=excl.districtcode and excl.administrationid=ds.AdministrationID
	Left JOIN Site.Attributes C ON C.SiteID = ds.SiteID and C.AdministrationID = ds.AdministrationID 
		  and C.AttributeName = 'County' and C.AttributeValue <> ''
		Left JOIN Site.Attributes IU ON IU.SiteID = ds.SiteID and IU.AdministrationID = ds.AdministrationID 
		  and IU.AttributeName = 'IUCode'  and IU.AttributeValue <> ''
	outer apply
	(
	select  sess.AdministrationID,sess.districtcode,sess.schoolcode,
	case when sum(case when tk.Status='Completed' then 1 else 0 end) > 0 then 1 else 0 end Participating 
	 from 
	Document.TestTicketView tk 
	inner join TestSession.Links ls on tk.AdministrationID=ls.AdministrationID and tk.DocumentID=ls.DocumentID 
	inner join Core.Student stud on stud.AdministrationID=ls.AdministrationID and stud.StudentID=ls.StudentID and stud.Grade in ('06','07','08','09','10','11','12','HS')
	inner join Scoring.TestForms tf on tk.AdministrationID=tf.AdministrationID and tk.Test=tf.Test and tk.Level=tf.Level and tk.Form=tf.Form and tf.Format='CAT'
	inner join Core.TestSession sess on sess.AdministrationID=ls.AdministrationID and sess.TestSessionID=ls.TestSessionID
	where not sess.SchoolCode in (select schoolcode from eWeb.UsageReportSitesToBeExcluded where districtcode = sess.DistrictCode and schoolcode = sess.SchoolCode)
	group by sess.AdministrationID,sess.DistrictCode,sess.SchoolCode
	having sess.AdministrationID=os.AdministrationID and sess.DistrictCode=os.SuperSiteCode and sess.SchoolCode=os.SiteCode
	) pct
	where os.AdministrationID=@AdministrationId  and os.SiteType='School' and ds.SiteSubType='04'
	and (C.AttributeValue=@CountyCode or @CountyCode='') and (iu.AttributeValue=@IUCode or @IUCode='')
	 and excl.AdministrationID is null
End
GO
