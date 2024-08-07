USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[SubmitOnlineTestIAT]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [Insight].[SubmitOnlineTestIAT]
	@AdministrationID int,
	@DocumentID int,
	@Method varchar(20),
	@Items xml,
	@Telemetry xml,
	@ComputerDetails xml
as
set nocount on; set transaction isolation level read uncommitted; set xact_abort on;

declare @OnlineTestID int,@TestEventID int,@Test varchar(50),@Level varchar(20),@Form varchar(20);
declare @CreateDate datetime=getdate();

select @Test=Test,@Level=Level,@Form=Form
from Document.TestTicket
where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

begin tran

insert Insight.OnlineTests (AdministrationID,DocumentID,Method,CreateDate)
select @AdministrationID,@DocumentID,@Method,@CreateDate;

set @OnlineTestID=scope_identity();

select @TestEventID=TestEventID
from Core.TestEvent
where AdministrationID=@AdministrationID and DocumentID=@DocumentID and Test=@Test and Level=@Level and Form=@Form;

if (@TestEventID is null) begin
	set @TestEventID=next value for Core.TestEvent_SeqEven;

	insert Core.TestEvent (AdministrationID,DocumentID,TestEventID,Test,Level,Form,CreateDate,UpdateDate)
	select @AdministrationID,@DocumentID,@TestEventID,@Test,@Level,@Form,@CreateDate,@CreateDate;
end else begin
	update Core.TestEvent set UpdateDate=@CreateDate where AdministrationID=@AdministrationID and TestEventID=@TestEventID
 
	delete from TestEvent.ItemScores where AdministrationID=@AdministrationID and TestEventID=@TestEventID
 
	delete from TestEvent.TestScores where AdministrationID=@AdministrationID and TestEventID=@TestEventID
end;

insert TestEvent.ItemScores (AdministrationID,TestEventID,Test,ItemID,DetailID,Response,Attempt,Correct,RawScore,Position,UsedForScore,CorrectResponse,Difficulty,ItemVersion)
select AdministrationID=@AdministrationID,TestEventID=@TestEventID,Test=@Test,i.ItemID,d.DetailID,
	Response=case when i.Response='' then '-' else i.Response end,		
	Attempt=case when i.Response in ('-', '') then 0 else 1 end,		
	Correct=case when i.Response=d.CorrectResponse then 1 else 0 end,
	RawScore=case when i.Response=d.CorrectResponse then d.MaxScore else 0 end,
	f.Position,
	UsedForScore=NULL,													
	d.CorrectResponse,
	Difficulty=NULL,
	i.ItemVersion													
from @Items.nodes('//Item') items(item)
cross apply (select ItemVersion=item.value('@itemVersion','varchar(100)'),ItemID=item.value('@itemId','varchar(50)'),Position=item.value('@sequence','int'),Response=substring(item.value('(./response/multiplechoiceinput/mcresponse/@value)[1]','varchar(10)'),2,1)) i /*NY: removed reference to UsedForScore and DiagnosticCategoryID*/
inner join Scoring.ItemDetails d on d.AdministrationID=@AdministrationID and d.Test=@Test and d.ItemID=i.ItemID and d.DetailID='0'
inner join Scoring.TestFormItems f on f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and f.Form=@Form and f.ItemID=i.ItemID
option (loop join); -- prevents deadlocks on FK check


insert TestEvent.TestScores (AdministrationID,TestEventID,Test,Score,RawScore,ItemsAttempted,AttemptedStatus,RescoreFlag,MaxRawScore,MaxItemsAttempted)
select AdministrationID=@AdministrationID,TestEventID=@TestEventID,Test=@Test,Score=tfs.Score,
	RawScore=isnull(sum(i.RawScore), 0.0),
	ItemsAttempted=isnull(sum(cast(i.Attempt as int)), 0),
	AttemptedStatus=isnull(max(i.Attempt), 0),
	RescoreFlag=0,
	MaxRawScore=tfs.MaxRawScore,
	MaxItemsAttempted=tfs.MaxItemsAttempted
from Scoring.TestFormScores tfs
inner join Scoring.TestFormScoreItems tfsi on tfsi.AdministrationID=@AdministrationID and tfsi.Test=@Test and tfsi.Level=@Level and tfsi.Form=@Form and tfsi.Score=tfs.Score
left join TestEvent.ItemScores i on i.AdministrationID=@AdministrationID and i.TestEventID=@TestEventID and i.Test=@Test and i.ItemID=tfsi.ItemID and i.DetailID=tfsi.DetailID
where tfs.AdministrationID=@AdministrationID and tfs.Test=@Test and tfs.Level=@Level and tfs.Form=@Form
group by tfs.Score, tfs.MaxRawScore, tfs.MaxItemsAttempted
option (loop join); -- prevents deadlocks on FK check

if (@Telemetry is not null) begin
	insert Insight.OnlineTestTelemetry (AdministrationID,OnlineTestID,Telemetry)
	select @AdministrationID,@OnlineTestID,cast(@Telemetry as nvarchar(max));
end;

if (@ComputerDetails is not null) begin
	insert Insight.OnlineTestComputerDetails (AdministrationID,OnlineTestID,ComputerDetails)
	select @AdministrationID,@OnlineTestID,cast(@ComputerDetails as nvarchar(max));
end;

insert Document.TestTicketStatus (AdministrationID,DocumentID,StatusTime,Status)
select @AdministrationID,@DocumentID,@CreateDate,'Completed';

commit tran;

select [@category]=ts.Score, [@rawScore] =ts.RawScore, [@maxRawScore] = ts.MaxRawScore 	
from TestEvent.TestScores ts
where ts.AdministrationID=@AdministrationID and ts.TestEventID=@TestEventID
order by ts.Score
for xml path('ScoreResult'), root('ScoreResults'), type;
GO
