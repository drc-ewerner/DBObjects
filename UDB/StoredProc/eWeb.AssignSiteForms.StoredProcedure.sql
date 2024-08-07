USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[AssignSiteForms]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [eWeb].[AssignSiteForms] 	
	@AdministrationID int,
	@Apply tinyint,
	@IgnorePaper tinyint
as

set nocount on;

declare @RequestResult table(
    AdministrationID int not null,
    DistrictCode varchar(10),
    SchoolCode varchar(10),
    District varchar(50),
    School varchar(50),
    Test varchar(50),
    Level varchar(20),
    Description varchar(100),
    NewForm varchar(20),
    Started int,
    Changing int,
    Status varchar(20),
    StartTime datetime 
);


with epic as (
	select distinct s.AdministrationID,s.DistrictCode,s.SchoolCode,District=(select SiteName from Core.Site d where d.AdministrationID=s.AdministrationID and d.SiteCode=s.DistrictCode and d.LevelID=1),School=x.SiteName,s.Test,s.Level,EpicForm=e.Form
	from Core.TestSession s 
	inner join Core.Site x on x.AdministrationID=s.AdministrationID and x.SuperSiteCode=s.DistrictCode and x.SiteCode=s.SchoolCode
	inner join Site.Attributes a on a.AdministrationID=s.AdministrationID and a.SiteID=x.SiteID and a.AttributeName like s.Test+'%formset' 
	inner join State.EpicFormSets e on e.AdministrationID=s.AdministrationID and e.Test=s.Test and e.Level=s.Level and e.EpicFormSet=a.AttributeValue
), a as (
	select s.AdministrationID,s.DistrictCode,s.SchoolCode,s.Test,s.Level,Form=min(t.Form),Form2=max(t.Form),Started=count(case when t.Status!='Not Started' then 1 end),Total=count(*),ff=count(distinct t.Form),StartTime=min(t.StartTime)
	from Core.TestSession s 
	inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
	inner join Document.TestTicketView t on t.administrationid=s.administrationid and t.documentid=k.documentid
	group by s.AdministrationID,s.DistrictCode,s.SchoolCode,s.Test,s.Level
)

insert @RequestResult
select a.AdministrationID,a.DistrictCode,a.SchoolCode,e.District,e.School,l.Test,l.Level,l.Description,NewForm=e.EpicForm,Started,Changing=Total-Started,Status=case when Started>0 then 'Invalid-Started' when (@IgnorePaper=0 and l.Description like '$ Paper%') then 'Invalid-Paper' else 'OK' end,StartTime
from a
inner join epic e on e.AdministrationID=a.AdministrationID and e.DistrictCode=a.DistrictCode and e.SchoolCode=a.SchoolCode and e.Test=a.Test and e.Level=a.Level
inner join Scoring.TestLevels l on l.AdministrationID=a.AdministrationID and l.Test=a.Test and l.Level=a.Level
where a.AdministrationID=@AdministrationID and District not like 'Sample District%' and (Form!=EpicForm or Form2!=EpicForm);


select AdministrationID,DistrictCode,SchoolCode,District,School,Test,Level,Description,NewForm,Started,Changing,Status,StartTime
from @RequestResult;

if (@Apply!=1) return;

if exists(select * from @RequestResult where Status!='OK') return;

with up as (
	select q.AdministrationID,t.DocumentID,q.NewForm
	from @RequestResult q
	inner join Core.TestSession s on s.AdministrationID=q.AdministrationID and s.DistrictCode=q.DistrictCode and s.SchoolCode=q.SchoolCode and s.Test=q.Test and s.Level=q.Level
	inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
	inner join Document.TestTicket t on t.AdministrationID=s.AdministrationID and t.DocumentID=k.DocumentID
	where q.Status='OK'
)
update Document.TestTicket set Form=up.NewForm
from Document.TestTicket t
inner join up on up.AdministrationID=t.AdministrationID and up.DocumentID=t.DocumentID;
GO
