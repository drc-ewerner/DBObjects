USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketAssignLevel]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[TestTicketAssignLevel]
	@AdministrationID int,
	@DocumentID int

as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare 
	@_AdministrationID int,
	@Username varchar(50),
	@Password varchar(20),
	@CountScores int,
	@ScoresNeeded int,
	@TestSessionID int,
	@LocatorScore decimal(10,5),
	@SubTest varchar(50),
	@SubLevel varchar(20),
	@Form varchar(20),
	@StudentID int,
	@NewTest varchar(50),
	@NewLevel varchar(20),
	@Spiraled int

create table #f (AdministrationID int,
				  Test varchar(50),
				  Level varchar(20),
				  Form varchar(20),
				  FormPart varchar(10),
				  Type char(1),
				  DocumentID int,
				  BaseDocumentID int,
				  Status varchar(50),
				  RawScore decimal(10,5),
				  NewForm varchar(20),
				  PlaceholderForm varchar(20),
				  NewTest varchar(50),
				  NewLevel varchar(20),
				  Spiraled int
				  )

set @_AdministrationID=@AdministrationID

select @Username=t.UserName,@TestSessionID=l.TestSessionID,@Password=t.Password,@SubTest=stl.SubTest,@SubLevel=stl.SubLevel,@StudentID=l.StudentID
from Document.TestTicket t
inner join TestSession.Links l on t.AdministrationID=l.AdministrationID and t.DocumentID=l.DocumentID
inner join Core.TestSession ts on t.AdministrationID=ts.AdministrationID and l.TestSessionID=ts.TestSessionID
inner join TestSession.SubTestLevels stl on stl.AdministrationID=t.AdministrationID and stl.TestSessionID=l.TestSessionID
inner join Scoring.MultiModuleTicketParts mm on t.AdministrationID=mm.AdministrationID and stl.SubTest=mm.Test and stl.SubLevel=mm.Level and t.Test=mm.PartTest and t.Level=mm.PartLevel and t.Form=mm.FormPart
where t.AdministrationID=@AdministrationID and t.DocumentID=@DocumentID

insert #f (Test,Level,Type,AdministrationID,DocumentID,BaseDocumentID,Form,FormPart,PlaceholderForm,Status)
select t.Test,t.Level,case when f.SpiralingOption='Placeholder' then 'D' else 'R' end,@AdministrationID,t.DocumentID,t.BaseDocumentID,t.Form,mm.PartName,
	case when f.SpiralingOption='Placeholder' then f.Form end,t.Status		
from Document.TestTicketView t
inner join TestSession.Links l on t.AdministrationID=l.AdministrationID and t.DocumentID=l.DocumentID
inner join Core.TestSession ts on t.AdministrationID=ts.AdministrationID and l.TestSessionID=ts.TestSessionID
inner join Scoring.MultiModuleTicketParts mm on t.AdministrationID=mm.AdministrationID and @SubTest=mm.Test and @SubLevel=mm.Level and t.Test=mm.PartTest and t.Level=mm.PartLevel and t.Form=mm.FormPart
inner join Scoring.TestForms f on t.AdministrationID=f.AdministrationID and t.Test=f.Test and t.Level=f.Level and mm.Form=f.Form
where t.AdministrationID=@AdministrationID and t.UserName=@Username and t.Password=@Password and l.TestSessionID=@TestSessionID

update #f set RawScore=ts.RawScore
from #f f
inner join Scoring.TestScoreExtensions e on e.AdministrationID=f.AdministrationID and e.Test=f.Test and e.Name='SpiralingScoreSet' and e.Value='Y'
inner join Core.TestEvent te on te.AdministrationID=f.AdministrationID and te.DocumentID=isnull(f.BaseDocumentID,f.DocumentID)
inner join TestEvent.TestScores ts on te.AdministrationID=ts.AdministrationID and te.TestEventID=ts.TestEventID and ts.Score=e.Score

select @CountScores=sum(case when Type='R' and Status='Completed' then 1 else 0 end),
	   @ScoresNeeded=sum(case when Type='R' then 1 else 0 end)
from #f

if @CountScores < @ScoresNeeded return;

select @LocatorScore = sum(RawScore) from (select max(RawScore) RawScore from #f where Type='R' group by BaseDocumentID)x

select distinct g.Form,tf.Test,tf.Level,tf.SpiralingOption,f.Test PH_Test, f.Level PH_Level 
into #forms
from #f f
inner join (
	select distinct e.Value,e.Test,e.Level
	from #f f
	cross apply (select top (1) Value,Test,Level from Scoring.TestFormGradeExtensions e where e.AdministrationID=f.AdministrationID and e.Test=f.Test and 
		e.Level=f.Level and Category='Level.Cut' and @LocatorScore <= CAST(Name as decimal(10,5)) order by CAST(Name as decimal(10,5)) asc) e
	where f.PlaceholderForm is not null) x on f.Test=x.Test and f.Level=x.Level
inner join Scoring.TestFormGradeExtensions g on g.AdministrationID=f.AdministrationID and g.Test=f.Test and 
	g.Level=f.Level and Category='Level.Cut' and g.Value=x.Value
inner join Scoring.TestForms tf on tf.AdministrationID=f.AdministrationID 
	and tf.Form=g.Form

declare @a table (Name varchar(50) not null, Test varchar(50) not null);

insert @a (Name,Test)
select Name,t.Test
from Student.Extensions e
inner join Scoring.Tests t on t.AdministrationID=e.AdministrationID and t.ContentArea=e.Category
inner join #forms f on f.Test=t.Test
where e.AdministrationID=@AdministrationID and StudentID=@StudentID and Category in (select ContentArea from Scoring.Tests where AdministrationID=@AdministrationID and Test in (select distinct Test from #forms)) and Value='Y';

select f.Form AccomForm,t.Test,t.Level,-1 Spiraled,
ROW_NUMBER() OVER (PARTITION BY t.test,t.level ORDER BY f.FormRule, f.Form, f.AccommodationName) AS rn
into #accomforms
from Scoring.TestAccommodationForms f
inner join #forms t on f.Test=t.Test and f.Level=t.Level and f.Form=t.Form
inner join @a a on a.Name=f.AccommodationName and a.Test=t.Test
where f.AdministrationID=@AdministrationID and f.Test=t.Test and f.Level=t.Level and (t.SpiralingOption is null or t.SpiralingOption!='Breach')
order by f.FormRule, f.Form, f.AccommodationName;

SELECT *,
        ROW_NUMBER() OVER (PARTITION BY test,level ORDER BY newid()) AS rn into #formx
FROM #forms where SpiralingOption is null

update #f set NewForm=isnull(af.AccomForm,x.Form),NewTest=x.Test,NewLevel=x.Level,Spiraled=isnull(af.Spiraled,-4)
from #f f
inner join #formx x on x.PH_Test=f.Test and x.PH_Level=f.Level
left join #accomforms af on af.Test=x.Test and af.Level=x.Level and af.rn=1
cross apply (select Test,Level from Scoring.TestForms tf where tf.AdministrationID=f.AdministrationID 
	and tf.Form=isnull(@Form,x.Form)+isnull('.'+case when FormPart='' then null else FormPart end,'')) tf
where f.PlaceholderForm is not null and x.rn=1

begin tran;
	update Document.TestTicket set Form=f.NewForm+isnull('.'+case when FormPart='' then null else FormPart end,''),Spiraled=f.Spiraled,Test=f.NewTest,Level=NewLevel
	from Document.TestTicket t
	inner join #f f on t.AdministrationID=@AdministrationID and t.DocumentID=f.DocumentID
	where f.NewForm is not null;

	if (@@ROWCOUNT>0) begin
		delete Document.TestTicket
		from #f f
		inner join Document.TestTicket t on f.AdministrationID=t.AdministrationID and f.DocumentID=t.DocumentID
		where f.Type='D' and f.NewForm is null
	end;
commit tran;

drop table #f
drop table #forms
drop table #formx
drop table #accomforms
GO
