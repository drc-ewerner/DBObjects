USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[ReportTierRespiraling]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[ReportTierRespiraling]
	@AdministrationID int,
	@TestSessionID int
--WITH RECOMPILE
as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

IF object_id('tempdb..#TicketReroute') is not null
begin
	drop table #TicketReroute
end
IF object_id('tempdb..#TestSess') is not null
begin
	drop table #TestSess
end

declare @UserNames table (
	StudentID int, 
	UserName varchar(50), 
	SessionTest varchar(50), 
	SessionLevel varchar(20), 
	TicketTest varchar(50), 
	TicketLevel varchar(20),
	SpiralingOption varchar(20), 
	PlaceholderForm varchar(20),
	DocumentID int, 
	Form varchar(20), 
	ContentArea varchar(50),
	AssignedSeq int,
	KeepIt int);

declare @ContMultModule char(1);

create table #TicketReroute (
	AdministrationID int,
	StudentID int,
	Form varchar(20),
	Test varchar(50),
	Level varchar(20))

create table #TestSess (
	AdministrationID int,
	TestSessionID int,
	StudentID int,
	DocumentID int)

select @ContMultModule=Value
from Config.Extensions
where AdministrationID=@AdministrationID and Category='Insight' and Name='ContinuousMultiModule' and Value='Y';

if (@ContMultModule='Y') begin
	insert into #TestSess
	select AdministrationID,TestSessionID,StudentID,min(DocumentID) DocumentID
	from TestSession.Links 
	where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID
	group by AdministrationID,TestSessionID,StudentID
end else begin
	insert into #TestSess
	select *
	from TestSession.Links
	where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID
end;

insert @UserNames (
	StudentID, 
	UserName,
	SessionTest,
	SessionLevel,
	TicketTest,
	TicketLevel,
	SpiralingOption,
	PlaceholderForm,
	ContentArea)
select	l.StudentID,
		tt.UserName,
		tt.Test,
		tt.Level,
		e.Name,
		e.Value,
		f.SpiralingOption,
		f.Form,
		t.ContentArea
from #TestSess l
inner join Document.TestTicket tt on l.AdministrationID=tt.AdministrationID and l.DocumentID=tt.DocumentID
inner join Scoring.TestFormGradeExtensions e on tt.AdministrationID=e.AdministrationID and tt.Test=e.Test and tt.Level=e.Level and
	e.Category='AssociateWith'
inner join Scoring.TestForms f on tt.AdministrationID=f.AdministrationID and e.Name=f.Test and e.Value=f.Level and
	f.SpiralingOption='Placeholder'
inner join Scoring.Tests t on l.AdministrationID=t.AdministrationID and e.Name=t.Test
where l.AdministrationID=@AdministrationID and l.TestSessionID=@TestSessionID

update @UserNames set DocumentID = tt.DocumentID, Form = case when tt.Form=u.PlaceholderForm then 'N/A' else coalesce(tf.Name,tfd.Name) end
from @UserNames u
inner join Document.TestTicket tt on tt.AdministrationID=@AdministrationID and tt.UserName=u.UserName and 
	tt.Test=u.TicketTest and tt.Level=u.TicketLevel
inner join TestSession.Links l on tt.AdministrationID=l.AdministrationID and tt.DocumentID=l.DocumentID
left join Scoring.TestFormGradeExtensions tf on tt.AdministrationID=tf.AdministrationID and tt.Test=tf.Test and
	tt.Level=tf.Level and tt.Form=tf.Form and tf.Category='TierPlacement.Cut'
left join Scoring.TestFormGradeExtensionsExcludeSpiral tfd on tt.AdministrationID=tfd.AdministrationID and tt.Test=tfd.Test and
	tt.Level=tfd.Level and tt.Form=tfd.Form and tfd.Category='TierPlacement.Cut'
where ((@ContMultModule='Y') and l.TestSessionID=@TestSessionID) or (isnull(@ContMultModule,'N')!='Y')

update @UserNames set DocumentID = tt.DocumentID, Form = 'Pre-A'
from @UserNames u
inner join Document.TestTicket tt on tt.AdministrationID=@AdministrationID and tt.UserName=u.UserName and 
	tt.Test=u.TicketTest and tt.Level=u.TicketLevel
inner join TestSession.Links l on tt.AdministrationID=l.AdministrationID and tt.DocumentID=l.DocumentID
inner join Scoring.TestFormGradeExtensions tf on tt.AdministrationID=tf.AdministrationID and tt.Test=tf.Test and
	tt.Level=tf.Level and tt.Form=tf.Form and tf.Category='PerfLevel'
where u.Form is null

declare @sql varchar(max)='';
select @sql=@sql+'insert into #TicketReroute (AdministrationID,StudentID,Form,Test,Level) 
exec Insight.TestTicketReportAssignTier '+cast(AdministrationID as varchar)+','+cast(DocumentID as varchar)+char(13)
from #TestSess l
where l.AdministrationID=@AdministrationID and l.TestSessionID=@TestSessionID
--select @sql
exec(@sql);

update UpdateUserNames 
set AssignedSeq=RowNum 
From (select AssignedSeq,ROW_NUMBER() OVER( PARTITION BY StudentID,ContentArea ORDER BY DocumentID desc)as RowNum
	  from @UserNames) as UpdateUserNames

select --distinct 
	@AdministrationID as AdministrationID,
	s.StudentID, 
	s.StateStudentID, 
	s.LastName, 
	s.FirstName, 
	s.Grade, 
	s.DistrictCode, 
	ds.SiteName as DistrictName, 
	s.SchoolCode,
	ss.SiteName as SchoolName, 
	convert(varchar,s.BirthDate,101) as BirthDate,
	max(case when u.ContentArea = 'Writing' then coalesce(u.Form,tr.Form,'N/A') end) as WritingTier,
	max(case when u.ContentArea = 'Speaking' then coalesce(u.Form,tr.Form,'N/A') end) as SpeakingTier
from @UserNames u
inner join Core.Student s on @AdministrationID=s.AdministrationID and u.StudentID=s.StudentID
inner join Core.Site ds on s.AdministrationID=ds.AdministrationID and s.DistrictCode=ds.SiteCode and ds.LevelID=1
inner join Core.Site ss on s.AdministrationID=ss.AdministrationID and s.SchoolCode=ss.SiteCode and s.DistrictCode=ss.SuperSiteCode
left join #TicketReroute tr on u.StudentID=tr.StudentID and u.TicketTest=tr.Test and u.TicketLevel=tr.Level
where u.SpiralingOption='Placeholder' and AssignedSeq=1 --and u.ContentArea = 'Writing'
group by s.StudentID,s.StateStudentID,s.LastName,s.FirstName,s.Grade,s.DistrictCode,ds.SiteName,s.SchoolCode,ss.SiteName,s.BirthDate

drop table #TicketReroute
drop table #TestSess
GO
