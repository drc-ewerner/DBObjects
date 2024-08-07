USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketRegenerateRespiraledTickets]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[TestTicketRegenerateRespiraledTickets]
	@AdministrationID int,
    @DocumentID int,
	@Test varchar(50),
	@Level varchar(20),
	@Username varchar(50),
	@UserID uniqueidentifier=null,
	@ActionUserName nvarchar(256)=null

as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @f table (Test varchar(50),Level varchar(20),Form varchar(20),Type char(1),DocumentID int,
				  PlaceholderForm varchar(20),StartTime datetime)

insert @f (Test,Level,Type)
select Name,Value,'R'
from Scoring.TestFormGradeExtensions tle
where tle.AdministrationID=@AdministrationID and tle.Test=@Test and tle.Level=@Level and tle.Category='AssociateWith'

update @f set Type='D',PlaceholderForm=f.Form
from @f at 
inner join Scoring.TestForms f on f.AdministrationID=@AdministrationID and f.Test=at.Test and f.Level=at.Level
	and f.SpiralingOption='Placeholder'

update @f set Form=t.Form,
			  DocumentID=t.DocumentID,
			  StartTime=t.StartTime
from @f at 
inner join Document.TestTicketView t on t.AdministrationID=@AdministrationID and t.Test=at.Test and t.Level=at.Level
	and t.UserName=@Username
inner join TestSession.Links l on t.AdministrationID=l.AdministrationID and t.DocumentID=l.DocumentID

IF object_id('tempdb..#r') is not null
begin
	drop table #r
end

create table #r (DocumentID int, PriorDocumentID int);

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
	@UserParam+@ActionParam+',''Respiral to Placeholder'''+char(13)
from @f
where (StartTime is not null or Form!=PlaceholderForm) and Type='D' and DocumentID!=@DocumentID
--select @sql
exec(@sql);

update #r set PriorDocumentID=f.DocumentID
from #r r
inner join @f f on r.DocumentID=f.DocumentID

update #r set PriorDocumentID=e.Value
from #r r
inner join Document.Extensions e on e.AdministrationID=@AdministrationID and e.DocumentID=r.DocumentID
	and e.Name='RegeneratedFromDocumentID'
where r.PriorDocumentID is null

update Document.TestTicket set Form=f.PlaceholderForm,Spiraled=-2
from #r r
inner join @f f on r.PriorDocumentID=f.DocumentID
inner join Document.TestTicket t on t.AdministrationID=@AdministrationID and t.DocumentID=r.DocumentID
where (StartTime is not null or t.Form!=PlaceholderForm) and Type='D' and f.DocumentID!=@DocumentID

--select * from @f
--select * from #r

drop table #r
GO
