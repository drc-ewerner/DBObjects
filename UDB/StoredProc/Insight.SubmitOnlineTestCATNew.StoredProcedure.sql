USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[SubmitOnlineTestCATNew]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[SubmitOnlineTestCATNew]
  @AdministrationID int,
  @DocumentID int,
  @Method varchar(20),
  @Items xml,
  @Telemetry xml,
  @Scores xml,
  @ComputerDetails xml,
  @LocalTimeOffset varchar(10) = null,
  @Timezone varchar(5) = null
with recompile
as
set nocount on; set transaction isolation level read uncommitted; set xact_abort on;

declare @OnlineTestID int,@TestEventID int,@Test varchar(50),@Level varchar(20),@Form varchar(20),@Source varchar(3)= 'CAT',@Status varchar(11)='Scored.CAT';
declare @CreateDate datetime=getdate();
declare @SpiralMethod varchar(1000);
declare @TestDuration float;
declare @DisplayColor varchar(100);

declare @itemscores table(
  ItemID varchar(50),
  DetailID varchar(20),
  Response varchar(10),
  Attempt tinyint,
  Correct tinyint,
  RawScore decimal(10, 5),
  NonScoreCode varchar(3),
  Density varchar(50),
  Position INT,
  UsedForScore varchar(50),
  CorrectResponse varchar(10),
  Difficulty decimal(10, 5),
  Status varchar(50)
);

declare @testscores table(
  Score varchar(50),
  RawScore decimal(10,5),
  ScaleScore decimal(10,5),
  SEM decimal(10,5),
  SEMUpper decimal(10,5),
  SEMLower decimal(10,5),
  Ability decimal(10,5),
  ScaleFactor decimal(15,10),
  ScaleBase decimal(15,10)
);

set @TestDuration=@Items.value('(//TelemetrySummary/@duration.sec)[1]','float');

select @Test=Test,@Level=Level,@Form=Form
from Document.TestTicket
where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

select @SpiralMethod=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','SpiralingMethod','')

select @DisplayColor=Value from Config.Extensions where AdministrationID=@AdministrationID and Category='Insight' and Name='ResultsDisplayColor'

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

insert @itemscores (ItemID,DetailID,Response,Attempt,Correct,RawScore,Position,UsedForScore,CorrectResponse,Difficulty,Status)
select i.ItemID,d.DetailID,i.Response,Attempt,Correct=case when i.Response=d.CorrectResponse then 1 else 0 end,RawScore,i.Position,UsedForScore=isnull(c.Score,i.UsedForScore),d.CorrectResponse,Difficulty=case when isnumeric(x.Value)=1 then cast(x.Value as decimal(10,5)) else null end,@Status
from @Items.nodes('//Item/scores/score') scores(score)
cross apply (select ItemID=score.value('../../@itemId','varchar(50)'),Position=score.value('../../@sequence','int'),Response=substring(score.value('(../../response/multiplechoiceinput/mcresponse/@value)[1]','varchar(10)'),2,1),UsedForScore=score.value('../../@abilityAttributeID','varchar(50)'),DetailID=score.value('@componentID','varchar(50)'),RawScore=score.value('.','int'),Attempt=case when score.value('(../..//@answered)[1]','varchar(50)')='y' then 1 else 0 end) i
inner join Scoring.ItemDetails d on d.AdministrationID=@AdministrationID and d.Test=@Test and d.ItemID=i.ItemID and d.DetailID=i.DetailID
left join Scoring.ItemExtensions x on x.AdministrationID=d.AdministrationID and x.Test=d.Test and x.ItemID=d.ItemID and x.Name='IRT_B'
left join Scoring.TestScoreExtensions c on c.AdministrationID=d.AdministrationID and c.Test=d.Test and c.Name='DiagnosticCategoryID' and c.Value=i.UsedForScore;

insert @testscores (Score,RawScore,ScaleScore,Ability,SEM,SEMUpper,SEMLower,ScaleFactor,ScaleBase)
select Score=isnull(c.Score,s.Score),s.RawScore,s.ScaleScore,s.Ability,s.SEM,s.SEMUpper,s.SEMLower,s.ScaleFactor,s.ScaleBase
from @Scores.nodes('//TestScore') xs(score)
cross apply (select Score=score.value('@name','varchar(50)'),RawScore=score.value('@rawScore','decimal(10,5)'),ScaleScore=score.value('@scaleScore','decimal(10,5)'),Ability=score.value('@ability','decimal(10,5)'),SEM=score.value('@sem','decimal(10,5)'),SEMUpper=score.value('@semUpper','decimal(10,5)'),SEMLower=score.value('@semLower','decimal(10,5)'),ScaleFactor=score.value('@scaleFactor','decimal(15,10)'),ScaleBase=score.value('@scaleBase','decimal(15,10)')) s
left join Scoring.TestScoreExtensions c on c.AdministrationID=@AdministrationID and c.Test=@Test and c.Name='DiagnosticCategoryID' and c.Value=s.Score;

insert Insight.OnlineTestItemScores (AdministrationID,OnlineTestID,ItemID,DetailID,Attempt,Correct,RawScore,UsedForScore,CorrectResponse,Difficulty)
select AdministrationID=@AdministrationID,OnlineTestID=@OnlineTestID,ItemID,DetailID,Attempt,Correct,RawScore,UsedForScore,CorrectResponse,Difficulty
from @itemscores;

insert Insight.OnlineTestTestScores (AdministrationID,OnlineTestID,Score,RawScore,ScaleScore,Ability,SEM,SEMUpper,SEMLower,ScaleFactor,ScaleBase)
select AdministrationID=@AdministrationID,OnlineTestID=@OnlineTestID,Score,RawScore,ScaleScore,Ability,SEM,SEMUpper,SEMLower,ScaleFactor,ScaleBase
from @testscores;

select @TestEventID=TestEventID from Core.TestEvent where AdministrationID=@AdministrationID and DocumentID=@DocumentID

If @TestEventID is null begin
  set @TestEventID=next value for Core.TestEvent_SeqEven;

  insert Core.TestEvent (AdministrationID,DocumentID,TestEventID,Test,Level,Form,CreateDate,UpdateDate)
  select @AdministrationID,@DocumentID,@TestEventID,@Test,@Level,@Form,@CreateDate,@CreateDate;

  insert TestEvent.ItemScores (AdministrationID,TestEventID,Test,ItemID,DetailID,Response,Attempt,Correct,RawScore,Position,UsedForScore,CorrectResponse,Difficulty,Status)
  select AdministrationID=@AdministrationID,TestEventID=@TestEventID,Test=@Test,ItemID,DetailID,Response,Attempt,Correct,RawScore,Position,UsedForScore,CorrectResponse,Difficulty,Status
  from @itemscores;
  
  insert TestEvent.TestScores (AdministrationID,TestEventID,Test,Score,RawScore,ScaleScore,Ability,SEM,SEMUpper,SEMLower,ScaleFactor,ScaleBase)
  select AdministrationID=@AdministrationID,TestEventID=@TestEventID,Test=@Test,Score,RawScore,ScaleScore,Ability,SEM,SEMUpper,SEMLower,ScaleFactor,ScaleBase
  from @testscores;
end;

if (@Telemetry is not null)
insert Insight.OnlineTestTelemetry (AdministrationID,OnlineTestID,Telemetry)
select @AdministrationID,@OnlineTestID,cast(@Telemetry as nvarchar(max));

if (@ComputerDetails is not null) begin
  insert Insight.OnlineTestComputerDetails (AdministrationID,OnlineTestID,ComputerDetails)
  select @AdministrationID,@OnlineTestID,cast(@ComputerDetails as nvarchar(max));
end;

insert Document.TestTicketStatus (AdministrationID,DocumentID,StatusTime,Status,LocalTimeOffset,Timezone)
select @AdministrationID,@DocumentID,@CreateDate,'Completed',@LocalTimeOffset,@Timezone;

commit tran;

if (@SpiralMethod='UsePlaceholder')
  exec Insight.TestTicketRespiral @AdministrationID, @DocumentID;

declare @Map varchar(50),@ContentArea varchar(50),@Description varchar(100),@FullLevel varchar(20);

select @FullLevel=case when CHARINDEX('-',@Level)=0 then @Level else SUBSTRING(@Level,1,CHARINDEX('-',@Level)-1) end

select top(1) @Map=tmx.Map,@Description=tmx.Value,@ContentArea=t.ContentArea
from Core.TestEvent e
inner join Core.Document d on d.AdministrationID=e.AdministrationID and d.DocumentID=e.DocumentID
inner join Core.Student s on s.AdministrationID=e.AdministrationID and s.StudentID=d.StudentID
inner join Scoring.Tests t on t.AdministrationID=e.AdministrationID and t.Test=e.Test
inner join Scoring.TestMapExtensions tm on tm.AdministrationID=e.AdministrationID and tm.Test=e.Test and tm.Name='Level' and tm.Value=@FullLevel
inner join Scoring.TestMapExtensions tmx on tmx.AdministrationID=e.AdministrationID and tmx.Test=e.Test and tmx.Map=tm.Map and tmx.Name in (replace('Grade.'+s.Grade,'.0','.'),'Grade.*')
where e.AdministrationID=@AdministrationID and e.TestEventID=@TestEventID
order by case when tmx.Name='Grade.*' then 2 else 1 end;

select
  ContentArea,Description,
  (
    select [@name]=tms.ScoreLabel,[@color]=isnull(@DisplayColor,tmr.DisplayInfo),[@text]=tmr.Label
    from Scoring.TestMapScores tms
    inner join TestEvent.TestScores ts on ts.AdministrationID=tms.AdministrationID and ts.Test=tms.Test and ts.Score=tms.Score
    cross apply (select Label,DisplayInfo from Scoring.TestMapRanges x where x.AdministrationID=tms.AdministrationID and x.Test=tms.Test and x.Map=tms.Map and x.RangeType='Color' and ts.ScaleScore between x.MinScaleScore and x.MaxScaleScore) tmr
    where ts.AdministrationID=@AdministrationID and ts.TestEventID=@TestEventID and tms.Map=@Map and tms.Score!='ALL'
    order by tms.DisplayOrder
    for xml path('DiagnosticCategory'), root('DiagnosticCategories'), type
  )
from (select ContentArea=@ContentArea,Description=@Description) TestResult	
for xml auto, elements, type;
GO
