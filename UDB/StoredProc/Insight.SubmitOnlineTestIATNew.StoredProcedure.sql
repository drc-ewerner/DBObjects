USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[SubmitOnlineTestIATNew]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [Insight].[SubmitOnlineTestIATNew]
	@AdministrationID int,
	@DocumentID int,
	@Method varchar(20),
	@Items xml,
	@Telemetry xml,
	@ComputerDetails xml,
	@LocalTimeOffset varchar(10) = null,
	@Timezone varchar(5) = null
as
set nocount on; set transaction isolation level read uncommitted; set xact_abort on;

declare @OnlineTestID int,@TestEventID int,@Test varchar(50),@Level varchar(20),@Form varchar(20),@Source varchar(3)= 'IAT',@Status varchar(11)='Scored.CAT';
declare @CreateDate datetime=getdate();
declare @TestDuration float;

set @TestDuration=@Items.value('(//TelemetrySummary/@duration.sec)[1]','float');

select @Test=Test,@Level=Level,@Form=Form
from Document.TestTicket
where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

begin tran

insert Insight.OnlineTests (AdministrationID,DocumentID,Method,CreateDate,Source,ElapsedTime)
select @AdministrationID,@DocumentID,@Method,@CreateDate,@Source,@TestDuration*1000;

set @OnlineTestID=scope_identity();

insert Insight.OnlineTestResponses (AdministrationID,OnlineTestID,ItemID,Position,Response,ExtendedResponse,ItemVersion)
select AdministrationID=@AdministrationID,OnlineTestID=@OnlineTestID,ItemID=item.value('@itemId','varchar(50)'),Position=item.value('@sequence','int'),Response=case when Response='' then '-' else Response end,ExtendedResponse=case when Response is null then cast(item.query('.') as nvarchar(max)) end,ItemVersion=item.value('@itemVersion','varchar(100)')
from @Items.nodes('//Item') d(item)
cross apply (select Response=substring(item.value('(./response/multiplechoiceinput/mcresponse/@value)[1]','varchar(10)'),2,1)) r;

insert Insight.OnlineTestAttachments (AdministrationID,OnlineTestID,ItemID,AttachmentID,AttachmentInputID,FilePath)
select	AdministrationID=@AdministrationID,OnlineTestID=@OnlineTestID,
		ItemID=item.value('@itemId','varchar(50)'),
		e.attachment.value('@attachment_id', 'int') as AttachmentID,
		e.attachment.value('@input_id', 'varchar(100)') as AttachmentInputID,
		e.attachment.value('@filePath', 'varchar(max)') as FilePath
from @Items.nodes('//Item') d(item)
cross apply d.item.nodes('attachments/attachment') as e(attachment);

insert Insight.OnlineTestItemScores (AdministrationID,OnlineTestID,ItemID,DetailID,Attempt,Correct,RawScore,UsedForScore,CorrectResponse,Difficulty)
select AdministrationID=@AdministrationID,OnlineTestID=@OnlineTestID,i.ItemID,d.DetailID,Attempt,Correct=case when i.Response=d.CorrectResponse then 1 else 0 end,RawScore,UsedForScore=isnull(c.Score,i.UsedForScore),d.CorrectResponse,Difficulty=case when isnumeric(x.Value)=1 then cast(x.Value as decimal(10,5)) else null end
from @Items.nodes('//Item/scores/score') scores(score)
cross apply (select ItemID=score.value('../../@itemId','varchar(50)'),Position=score.value('../../@sequence','int'),Response=substring(score.value('(../../response/multiplechoiceinput/mcresponse/@value)[1]','varchar(10)'),2,1),UsedForScore=score.value('../../@abilityAttributeID','varchar(50)'),DetailID=score.value('@componentID','varchar(50)'),RawScore=score.value('.','int'),Attempt=case when score.value('(../..//@answered)[1]','varchar(50)')='y' then 1 else 0 end) i
inner join Scoring.ItemDetails d on d.AdministrationID=@AdministrationID and d.Test=@Test and d.ItemID=i.ItemID and d.DetailID=i.DetailID
left join Scoring.ItemExtensions x on x.AdministrationID=d.AdministrationID and x.Test=d.Test and x.ItemID=d.ItemID and x.Name='IRT_B'
left join Scoring.TestScoreExtensions c on c.AdministrationID=d.AdministrationID and c.Test=d.Test and c.Name='DiagnosticCategoryID' and c.Value=i.UsedForScore;

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

insert TestEvent.ItemScores (AdministrationID,TestEventID,Test,ItemID,DetailID,Response,Attempt,Correct,RawScore,Position,UsedForScore,CorrectResponse,Difficulty,Status,ItemVersion)
select AdministrationID=@AdministrationID,TestEventID=@TestEventID,Test=@Test,i.ItemID,d.DetailID,i.Response,Attempt,Correct=case when i.Response=d.CorrectResponse then 1 else 0 end,RawScore,i.Position,UsedForScore=isnull(c.Score,i.UsedForScore),d.CorrectResponse,Difficulty=case when isnumeric(x.Value)=1 then cast(x.Value as decimal(10,5)) else null end,@Status,i.ItemVersion
from @Items.nodes('//Item/scores/score') scores(score)
cross apply (select ItemID=score.value('../../@itemId','varchar(50)'),Position=score.value('../../@sequence','int'),Response=substring(score.value('(../../response/multiplechoiceinput/mcresponse/@value)[1]','varchar(10)'),2,1),UsedForScore=score.value('../../@abilityAttributeID','varchar(50)'),DetailID=score.value('@componentID','varchar(50)'),RawScore=score.value('.','int'),Attempt=case when score.value('(../..//@answered)[1]','varchar(50)')='y' then 1 else 0 end,ItemVersion=score.value('(../../@itemVersion)[1]','varchar(100)')) i
inner join Scoring.ItemDetails d on d.AdministrationID=@AdministrationID and d.Test=@Test and d.ItemID=i.ItemID and d.DetailID=i.DetailID
left join Scoring.ItemExtensions x on x.AdministrationID=d.AdministrationID and x.Test=d.Test and x.ItemID=d.ItemID and x.Name='IRT_B'
left join Scoring.TestScoreExtensions c on c.AdministrationID=d.AdministrationID and c.Test=d.Test and c.Name='DiagnosticCategoryID' and c.Value=i.UsedForScore
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

insert Document.TestTicketStatus (AdministrationID,DocumentID,StatusTime,Status,LocalTimeOffset,Timezone)
select @AdministrationID,@DocumentID,@CreateDate,'Completed',@LocalTimeOffset,@Timezone;

commit tran;

select [@category]=ts.Score, [@rawScore] =ts.RawScore, [@maxRawScore] = ts.MaxRawScore 	
from TestEvent.TestScores ts
where ts.AdministrationID=@AdministrationID and ts.TestEventID=@TestEventID
order by ts.Score
for xml path('ScoreResult'), root('ScoreResults'), type;
GO
