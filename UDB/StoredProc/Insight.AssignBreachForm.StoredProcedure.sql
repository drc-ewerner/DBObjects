USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[AssignBreachForm]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Insight].[AssignBreachForm]
	@AdministrationID int,
	@DocumentID int,
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

declare
	@NewDocumentID int,
	@Test varchar(20),
	@Level varchar(20),
	@PartName varchar(50),
	@Form varchar(20),
	@BaseDocumentID int,
	@NewTest varchar(5),
	@StudentID int,
	@TestSessionID int
;

declare @d table (
	DocumentID int not null,
	Form varchar(20),
	Test varchar(20),
	Level varchar(20),
	PartName varchar(50)
);	

declare @aforms table (Form varchar(20) not null);

declare @t table (DocumentID int, Status varchar(50), StudentID int, TestSessionID int);

--find all parts of the ticket
select @BaseDocumentID=BaseDocumentID,@Test=Test,@Level=Level
from Document.TestTicket
where AdministrationID=@AdministrationID and DocumentID=@DocumentID

--find the breach form for this admin/test/level
insert @aforms (Form)
select f.Form
from Scoring.TestForms f
where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and f.SpiralingOption='Breach';

--if no breach form or form already breach form do nothing
--if ((not exists(select * from @aforms)) or (@Form in (select * from @aforms))) return;
if (not exists(select * from @aforms)) begin
	select DocumentID= -1 
	return;
end;
	
if (@BaseDocumentID is null) begin
	insert @t (DocumentID,StudentID,TestSessionID)
	select @DocumentID,StudentID,TestSessionID
	from TestSession.Links where AdministrationID=@AdministrationID and DocumentID=@DocumentID
end else begin
	insert @t (DocumentID,Status,StudentID,TestSessionID)
	select t.DocumentID,t.Status,l.StudentID,l.TestSessionID
	from Document.TestTicketView t
	left join TestSession.Links l on t.AdministrationID=l.AdministrationID and t.DocumentID=l.DocumentID
	where t.AdministrationID=@AdministrationID and BaseDocumentID=@BaseDocumentID
end;

--determine if ticket(s) can be regenerated or if a new test needs to be created - if any part has ever been Completed then 
--current test needs to be purged and a new test created.  If no part has ever been Completed then the test can be regenerated.
select @NewTest=case when Status='Completed' then 'Yes' end,@StudentID=case when StudentID is not null then StudentID end,
	@TestSessionID=case when TestSessionID is not null then TestSessionID end
from @t
where Status='Completed'

declare @sql varchar(max)='';

if (@NewTest='Yes') begin
	select @sql=@sql+'exec Insight.TestTicketPurge '+cast(@AdministrationID as varchar)+','+cast(@DocumentID as varchar)+''+char(13)
	select @sql=@sql+'insert #r (DocumentID) exec Insight.TestTicketCreate '+cast(@AdministrationID as varchar)+','+cast(@TestSessionID as varchar)+','+
		cast(@StudentID as varchar)+',null,1000,'''+@Test+''','''+@Level+''''+char(13)
end else begin

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
		@UserParam+@ActionParam+',''Breach Form'''+char(13)
	from @t
	where TestSessionID is not null
end;
--select @sql
exec(@sql);

--get the DocumentID of the new/regenerated ticket
select top(1) @NewDocumentID=DocumentID from #r;

--get necessary information about the ticket

insert @d (DocumentID,Form,Test,Level,PartName)
select t.DocumentID,t.Form,t.Test,t.Level,t.PartName
from #r r
inner join Document.TestTicket t on t.AdministrationID=@AdministrationID and t.DocumentID=r.DocumentID

if (@@rowcount=0) return;

select top(1) @Form=Form,@Test=Test,@Level=Level,@PartName=PartName from @d;

--if the current form is multi-part get the base form 
if (@PartName is not null) select @Form=Form from Scoring.TestFormParts where AdministrationID=@AdministrationID and Test=@Test and Level=@Level and FormPart=@Form;
	
if (@Form in (select * from @aforms)) begin
	select DocumentID=@NewDocumentID
	return;
end;	

--otherwise assign the breach form
begin tran

		select top(1) @Form=Form from @aforms;
		
		update Document.TestTicket set Form=@Form+isnull('.'+PartName,'')--,Spiraled=-1
		where AdministrationID=@AdministrationID and DocumentID in (select DocumentID from @d);	
		
		insert Document.TestTicketStatus (AdministrationID,DocumentID,StatusTime,Status)
		select @AdministrationID,DocumentID,dateadd(ms,3,getdate()),'Regenerated.Breach'
		from @d;
		
commit tran;

--return the DocumentID - from RegenerateTicket with breach form now assigned
select DocumentID=@NewDocumentID;

return;
GO
