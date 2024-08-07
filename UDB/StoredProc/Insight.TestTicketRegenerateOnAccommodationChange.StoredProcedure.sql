USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketRegenerateOnAccommodationChange]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Insight].[TestTicketRegenerateOnAccommodationChange]
	@AdministrationID int,
	@StudentID int,
	@UserID uniqueidentifier=null,
	@ActionUserName nvarchar(256)=null

as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

set @ActionUserName=replace(@ActionUserName,'''','''''')

IF object_id('tempdb..#r') is not null
begin
	drop table #r
end

create table #r (DocumentID int);

declare @d table (n int identity,AdministrationID int,StudentID int,ContentArea varchar(50),Assessment varchar(1000),Test varchar(50),Level varchar(20),
	Form varchar(20),FormPart varchar(20),DocumentID int,StartTime datetime,EndTime datetime,BaseDocumentID int,TestSessionID int,Spiraled int,
	AccommodatedForm varchar(20),Action varchar(10));
declare @a table (StudentAccommodationName varchar(50),Category varchar(50),Test varchar(50),Level varchar(20),CurrentForm varchar(20),
	SpiralingOption varchar(20),AccommodatedForm varchar(20),IsAccomForm int,DocumentID int,Action varchar(10),TestSessionID int,FormRule varchar(20));
declare @f table (Form varchar(20),Name varchar(50),Test varchar(50),Level varchar(20));

insert into @d (AdministrationID,StudentID,ContentArea,Assessment,Test,Level,Form,DocumentID,StartTime,BaseDocumentID,TestSessionID,Spiraled)
select l.AdministrationID,l.StudentID,t.ContentArea,isnull(tl.Description,tl.Level),tt.Test,tt.Level,
	case when tt.PartName is null then tt.Form else left(tt.Form,charindex('.'+tt.PartName,tt.Form)-1) end,
	min(tt.DocumentID),max(tt.StartTime),isnull(tt.BaseDocumentID,l.DocumentID),
	l.TestSessionID,tt.Spiraled
from TestSession.Links l
inner join Document.TestTicketView tt on l.AdministrationID=tt.AdministrationID and l.DocumentID=tt.DocumentID
inner join Scoring.Tests t on tt.AdministrationID=t.AdministrationID and tt.Test=t.Test
inner join Scoring.TestLevels tl on tt.AdministrationID=tl.AdministrationID and tt.Test=tl.Test and tt.Level=tl.Level
where l.AdministrationID=@AdministrationID and l.StudentID=@StudentID
group by l.AdministrationID,l.StudentID,t.ContentArea,isnull(tl.Description,tl.Level),tt.Test,tt.Level,
	case when tt.PartName is null then tt.Form else left(tt.Form,charindex('.'+tt.PartName,tt.Form)-1) end,
	isnull(tt.BaseDocumentID,l.DocumentID),
	l.TestSessionID,tt.Spiraled

if (@@rowcount=0) begin
	insert into @d (AdministrationID,StudentID,Action)
	select @AdministrationID,@StudentID,'NoTests';
end;

update @d set EndTime=t.EndTime
from @d d
inner join Document.TestTicketView t on d.AdministrationID=t.AdministrationID and d.BaseDocumentID=t.BaseDocumentID
where d.BaseDocumentID is not null and t.EndTime is not null

--select 'd1',* from @d

insert @a (StudentAccommodationName,Category,Test,Level,CurrentForm,SpiralingOption,TestSessionID,IsAccomForm)
select distinct case when isnull(e.Value,'N') = 'Y' then e.Name end,d.ContentArea,d.Test,d.Level,d.Form,tf.SpiralingOption,
	d.TestSessionID,9
from @d d
inner join Scoring.TestForms tf on d.AdministrationID=tf.AdministrationID and d.Test=tf.Test and d.Level=tf.Level and d.Form=tf.Form
left join Student.Extensions e on e.AdministrationID=d.AdministrationID and e.StudentID=d.StudentID and e.Category=d.ContentArea
	and e.Name like 'Online%' and e.Value='Y'
--where e.Value='Y' and e.Name like 'Online%';
--where (e.Name like 'Online%' and e.Value='Y') or e.Name is null

--select 'a1',* from @a

update @a set AccommodatedForm=f.Form,IsAccomForm=1,FormRule=f.FormRule
from Scoring.TestAccommodationForms f
inner join Scoring.TestForms t on t.AdministrationID=f.AdministrationID and t.Test=f.Test and t.Level=f.Level and t.Form=f.Form
inner join @a a on a.StudentAccommodationName=f.AccommodationName and a.Test=f.Test and a.Level=f.Level
where f.AdministrationID=@AdministrationID and (t.SpiralingOption is null or t.SpiralingOption!='Breach');

update @a set StudentAccommodationName=null where AccommodatedForm is null;

--select 'a2',* from @a

update @a set DocumentID=d.DocumentID,Action = 
case when (a.StudentAccommodationName is null and a.SpiralingOption is null) or
		(a.StudentAccommodationName is not null and (a.CurrentForm = a.AccommodatedForm or a.AccommodatedForm is null)) then 'OK' else
		case when d.StartTime is not null or d.EndTime is not null then 'Started' else 
		case when (a.StudentAccommodationName is not null and a.CurrentForm != a.AccommodatedForm) or
		(a.StudentAccommodationName is null and a.SpiralingOption is not null) then 'Regen' end end end
from @d d
inner join @a a on d.Test=a.Test and d.Level=a.Level and d.Form=a.CurrentForm

--select 'a3',* from @a

update @d set AccommodatedForm=x.AccommodatedForm,Action=x.Action
from @d d
cross apply (select top 1 * from @a a where d.DocumentID=a.DocumentID order by a.IsAccomForm,a.FormRule,a.AccommodatedForm,a.StudentAccommodationName,a.Action) x
--where a.AccommodatedForm is not null

--select 'd2',* from @d

declare @sql varchar(max)='';

declare @UserParam varchar(40)
if (@UserID is null) begin
	set @UserParam=',null'
end else begin
	set @UserParam=','''+cast(@UserID as varchar(40))+''''
end

declare @ActionParam nvarchar(256)
if (@ActionUserName is null) begin
	set @ActionParam=',null'
end else begin
	set @ActionParam=','''+cast(@ActionUserName as nvarchar(256))+''''
end

select @sql=@sql+'insert #r (DocumentID) exec Insight.TestTicketRegenerate '+cast(@AdministrationID as varchar)+','+cast(DocumentID as varchar)+
	@UserParam+@ActionParam+',''AccommodationChange'''+char(13)
from @d
where Action='regen'
group by DocumentID,Action
--select @sql
exec(@sql);

select	ds.SiteName as DistrictName,
		s.DistrictCode,
		ss.SiteName as SchoolName,
		s.SchoolCode,
		s.LastName,
		s.FirstName,
		s.MiddleName,
		s.StateStudentID,
		s.DistrictStudentID,
		s.BirthDate,
		s.Grade,
		a.Assessment as AssessmentName,
		b.Name as SessionName,
		a.Action as MessageCode
from Core.Student s
inner join Core.Site ds on s.AdministrationID=ds.AdministrationID and s.DistrictCode=ds.SiteCode and ds.LevelID=1
inner join Core.Site ss on s.AdministrationID=ss.AdministrationID and s.SchoolCode=ss.SiteCode and s.DistrictCode=ss.SuperSiteCode
outer apply (select Assessment,Action,TestSessionID from @d) a
outer apply (select Name from Core.TestSession ts where ts.AdministrationID=@AdministrationID and ts.TestSessionID=a.TestSessionID) b
where s.AdministrationID=@AdministrationID and s.StudentID=@StudentID

drop table #r
GO
