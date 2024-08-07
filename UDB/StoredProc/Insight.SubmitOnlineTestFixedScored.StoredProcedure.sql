USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[SubmitOnlineTestFixedScored]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[SubmitOnlineTestFixedScored]
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

declare @OnlineTestID int,@TestEventID int,@Test varchar(50),@Level varchar(20),@Form varchar(20),@Source varchar(50)= 'Fixed',@Status varchar(50)='Scored.Fixed',@TEDocumentID int,@TestType varchar(30);
declare @SessionType varchar(30);
declare @CreateDate datetime=getdate();
declare @TestDuration float;

set @TestDuration=@Items.value('(//TelemetrySummary/@duration.sec)[1]','float');

select @Test=t.Test,@Level=t.Level,@Form=isnull(p.Form,t.Form),@TEDocumentID=isnull(t.BaseDocumentID,t.DocumentID),@TestType=l.OptionalProcessing
from Document.TestTicket t
inner join Scoring.TestLevels l on l.AdministrationID=t.AdministrationID and l.Test=t.Test and l.Level=t.Level
left join Scoring.TestFormParts p on p.AdministrationID=t.AdministrationID and p.Test=t.Test and p.Level=t.Level and p.FormPart=t.Form
where t.AdministrationID=@AdministrationID and t.DocumentID=@DocumentID;

if @TestType='locator' begin
	select @SessionType=tl.OptionalProcessing
	from Core.TestSession ts
	inner join TestSession.Links l on l.AdministrationID=ts.AdministrationID and l.TestSessionID=ts.TestSessionID
	inner join TestSession.SubTestLevels stl on stl.AdministrationID=ts.AdministrationID and stl.TestSessionID=l.TestSessionID
	inner join Scoring.MultiModuleTicketParts p on p.AdministrationID=ts.AdministrationID and p.PartTest=@Test and p.PartLevel=@Level and p.Test=stl.SubTest and p.Level=stl.SubLevel
	inner join Scoring.TestLevels tl on tl.AdministrationID=ts.AdministrationID and tl.Test=p.Test and tl.Level=p.Level
	where ts.AdministrationID=@AdministrationID and l.DocumentID=@DocumentID
end

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
where AdministrationID=@AdministrationID and DocumentID=@TEDocumentID and Test=@Test and Level=@Level and Form=@Form;

if (@TestEventID is null) begin
	set @TestEventID=next value for Core.TestEvent_SeqEven;

	insert Core.TestEvent (AdministrationID,DocumentID,TestEventID,Test,Level,Form,CreateDate,UpdateDate)
	select @AdministrationID,@TEDocumentID,@TestEventID,@Test,@Level,@Form,@CreateDate,@CreateDate;
end else begin
	update Core.TestEvent set UpdateDate=@CreateDate where AdministrationID=@AdministrationID and TestEventID=@TestEventID
 
	delete its 
	from TestEvent.ItemScores its where AdministrationID=@AdministrationID and TestEventID=@TestEventID and exists	
		(select * from Insight.OnlineTestResponses r where r.AdministrationID=its.AdministrationID and r.OnlineTestID=@OnlineTestID and r.ItemID=its.ItemID)
 --what if there are different items for some reason????
	delete from TestEvent.TestScores where AdministrationID=@AdministrationID and TestEventID=@TestEventID
	delete from TestEvent.TestStatus where AdministrationID=@AdministrationID and TestEventID=@TestEventID
end;

insert TestEvent.ItemScores (AdministrationID,TestEventID,Test,ItemID,DetailID,Response,Attempt,Correct,RawScore,Position,UsedForScore,CorrectResponse,Difficulty,Status,ItemVersion)
select AdministrationID=@AdministrationID,TestEventID=@TestEventID,Test=@Test,i.ItemID,d.DetailID,Response=case when i.Response='' then '-' else i.Response end,Attempt,Correct=case when i.Response=d.CorrectResponse then 1 else 0 end,RawScore,i.Position,UsedForScore=isnull(c.Score,i.UsedForScore),d.CorrectResponse,Difficulty=case when isnumeric(x.Value)=1 then cast(x.Value as decimal(10,5)) else null end,@Status,i.ItemVersion
from @Items.nodes('//Item/scores/score') scores(score)
cross apply (select ItemID=score.value('../../@itemId','varchar(50)'),Position=score.value('../../@sequence','int'),Response=substring(score.value('(../../response/multiplechoiceinput/mcresponse/@value)[1]','varchar(10)'),2,1),UsedForScore=score.value('../../@abilityAttributeID','varchar(50)'),DetailID=score.value('@componentID','varchar(50)'),RawScore=score.value('.','int'),Attempt=case when score.value('(../..//@answered)[1]','varchar(50)')='y' then 1 else 0 end,ItemVersion=score.value('(../../@itemVersion)[1]','varchar(100)')) i
inner join Scoring.ItemDetails d on d.AdministrationID=@AdministrationID and d.Test=@Test and d.ItemID=i.ItemID and d.DetailID=i.DetailID
left join Scoring.ItemExtensions x on x.AdministrationID=d.AdministrationID and x.Test=d.Test and x.ItemID=d.ItemID and x.Name='IRT_B'
left join Scoring.TestScoreExtensions c on c.AdministrationID=d.AdministrationID and c.Test=d.Test and c.Name='DiagnosticCategoryID' and c.Value=i.UsedForScore
option (loop join); -- prevents deadlocks on FK check

insert TestEvent.TestScores (AdministrationID,TestEventID,Test,Score,RawScore,ItemsAttempted,AttemptedStatus,RescoreFlag,MaxRawScore,MaxItemsAttempted,ScaleScore,PerformanceLevel)
select x.*,tfsp.ScaleScore,tfsp.PerformanceLevel from (
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
group by tfs.Score, tfs.MaxRawScore, tfs.MaxItemsAttempted) x
left join Scoring.TestFormScorePsychometrics tfsp on tfsp.AdministrationID=@AdministrationID and tfsp.Test=@Test and tfsp.Level=@Level and tfsp.Form=@Form and tfsp.Score=x.Score
	and tfsp.RawScore=x.RawScore
option (loop join); -- prevents deadlocks on FK check

if (@Telemetry is not null) begin
	insert Insight.OnlineTestTelemetry (AdministrationID,OnlineTestID,Telemetry)
	select @AdministrationID,@OnlineTestID,cast(@Telemetry as nvarchar(max));
end;

if (@ComputerDetails is not null) begin
	insert Insight.OnlineTestComputerDetails (AdministrationID,OnlineTestID,ComputerDetails)
	select @AdministrationID,@OnlineTestID,cast(@ComputerDetails as nvarchar(max));
end;

update Document.TestTicket set PartName=null
from Document.TestTicket t
inner join Scoring.TestFormExtensions e on e.AdministrationID=t.AdministrationID and e.Test=t.Test and e.Level=t.Level and e.Form=t.Form and e.Name='TestFamily' and e.Value='CLASE'
where t.AdministrationID=@AdministrationID and t.DocumentID=@DocumentID and t.PartName='' 

insert Document.TestTicketStatus (AdministrationID,DocumentID,StatusTime,Status,LocalTimeOffset,Timezone)
select @AdministrationID,@DocumentID,@CreateDate,'Completed',@LocalTimeOffset,@Timezone;

insert TestEvent.TestStatus (AdministrationID, TestEventID, Test, TestStatus)
select @AdministrationID,@TestEventID,@Test,'Sessions Missing'
where (
	select count(*) from Document.TestTicketView t
	inner join TestSession.Links l on t.AdministrationID=l.AdministrationID and t.DocumentID=l.DocumentID
	where t.AdministrationID=@AdministrationID and t.BaseDocumentID=@TEDocumentID and t.Status<>'Completed') > 0

if @SessionType='autolocator' begin
	exec Insight.TestTicketAssignLevel @AdministrationID,@DocumentID
end
commit tran;

select [@category]=ts.Score, [@rawScore] =ts.RawScore, [@maxRawScore] = ts.MaxRawScore 	
from TestEvent.TestScores ts
where ts.AdministrationID=@AdministrationID and ts.TestEventID=@TestEventID
order by ts.Score
for xml path('ScoreResult'), root('ScoreResults'), type;
GO
