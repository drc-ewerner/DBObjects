USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetUsageReportParticipationDistrict]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [eWeb].[GetUsageReportParticipationDistrict]
	@pAdministrationID integer, 
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


Begin
	select 'District' SiteType,isnull(sum(pct.Participating),0) Participating,
	COUNT(*) - isnull(sum(pct.Participating),0) NotParticipating, 
	Count(*) Total  from 
	core.site os  
	Left JOIN Site.Attributes C ON C.SiteID = os.SiteID and C.AdministrationID = os.AdministrationID 
		  and C.AttributeName = 'County' and C.AttributeValue <> ''
		Left JOIN Site.Attributes IU ON IU.SiteID = os.SiteID and IU.AdministrationID = os.AdministrationID 
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
		inner join Core.Site sc on sc.AdministrationID=sess.AdministrationID and sc.SiteCode=sess.SchoolCode and sc.SuperSiteCode=sess.DistrictCode
		where sc.SiteSubType <> '03'
		and not sess.SchoolCode in (select schoolcode from eWeb.UsageReportSitesToBeExcluded where districtcode = sess.DistrictCode and schoolcode = sess.SchoolCode)
		group by sess.AdministrationID,sess.DistrictCode
		having sess.AdministrationID=@AdministrationId and sess.DistrictCode=os.SiteCode 
		
	) pct
	where os.AdministrationID=@AdministrationId and  os.SiteType='District' and os.SiteSubType not in ('04','39')  
	and (C.AttributeValue=@CountyCode or @CountyCode='') and (iu.AttributeValue=@IUCode or @IUCode='')
End
GO
