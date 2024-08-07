USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[SubmitOnlineTestCAT]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [Insight].[SubmitOnlineTestCAT]
	@AdministrationID int,
	@DocumentID int,
	@Method varchar(20),
	@Items xml,
	@Telemetry xml,
	@Scores xml,
	@ComputerDetails xml
with recompile
as
set nocount on; set transaction isolation level read uncommitted; set xact_abort on;

declare @OnlineTestID int,@TestEventID int,@Test varchar(50),@Level varchar(20),@Form varchar(20);
declare @CreateDate datetime=getdate();

select @Test=Test,@Level=Level,@Form=Form
from Document.TestTicket
where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

begin tran;

insert Insight.OnlineTests (AdministrationID,DocumentID,Method,CreateDate)
select @AdministrationID,@DocumentID,@Method,@CreateDate;

set @OnlineTestID=scope_identity();

set @TestEventID=next value for Core.TestEvent_SeqEven;

insert Core.TestEvent (AdministrationID,DocumentID,TestEventID,Test,Level,Form,CreateDate,UpdateDate)
select @AdministrationID,@DocumentID,@TestEventID,@Test,@Level,@Form,@CreateDate,@CreateDate;


insert TestEvent.ItemScores (AdministrationID,TestEventID,Test,ItemID,DetailID,Response,Attempt,Correct,RawScore,Position,UsedForScore,CorrectResponse,Difficulty)
select AdministrationID=@AdministrationID,TestEventID=@TestEventID,Test=@Test,i.ItemID,d.DetailID,i.Response,Attempt=1,Correct=case when i.Response=d.CorrectResponse then 1 else 0 end,RawScore=case when i.Response=d.CorrectResponse then d.MaxScore else 0 end,i.Position,UsedForScore=isnull(c.Score,i.UsedForScore),d.CorrectResponse,Difficulty=case when isnumeric(x.Value)=1 then cast(x.Value as decimal(10,5)) else null end
from @Items.nodes('//Item') items(item)
cross apply (select ItemID=item.value('@itemId','varchar(50)'),Position=item.value('@sequence','int'),Response=substring(item.value('(./response/multiplechoiceinput/mcresponse/@value)[1]','varchar(10)'),2,1),UsedForScore=item.value('@diagnosticCategoryId','varchar(50)')) i
inner join Scoring.ItemDetails d on d.AdministrationID=@AdministrationID and d.Test=@Test and d.ItemID=i.ItemID and d.DetailID='0'
left join Scoring.ItemExtensions x on x.AdministrationID=d.AdministrationID and x.Test=d.Test and x.ItemID=d.ItemID and x.Name='IRT_B'
left join Scoring.TestScoreExtensions c on c.AdministrationID=d.AdministrationID and c.Test=d.Test and c.Name='DiagnosticCategoryID' and c.Value=i.UsedForScore;
	
insert TestEvent.TestScores (AdministrationID,TestEventID,Test,Score,ScaleScore,Ability,SEM,SEMUpper,SEMLower,ScaleFactor,ScaleBase)
select AdministrationID=@AdministrationID,TestEventID=@TestEventID,Test=@Test,Score=isnull(c.Score,s.Score),s.ScaleScore,s.Ability,s.SEM,s.SEMUpper,s.SEMLower,s.ScaleFactor,s.ScaleBase
from @Scores.nodes('//TestScore') xs(score)
cross apply (select Score=score.value('@name','varchar(50)'),ScaleScore=score.value('@scaleScore','decimal(10,5)'),Ability=score.value('@ability','decimal(10,5)'),SEM=score.value('@sem','decimal(10,5)'),SEMUpper=score.value('@semUpper','decimal(10,5)'),SEMLower=score.value('@semLower','decimal(10,5)'),ScaleFactor=score.value('@scaleFactor','decimal(15,10)'),ScaleBase=score.value('@scaleBase','decimal(15,10)')) s
left join Scoring.TestScoreExtensions c on c.AdministrationID=@AdministrationID and c.Test=@Test and c.Name='DiagnosticCategoryID' and c.Value=s.Score;

if (@Telemetry is not null)
insert Insight.OnlineTestTelemetry (AdministrationID,OnlineTestID,Telemetry)
select @AdministrationID,@OnlineTestID,cast(@Telemetry as nvarchar(max));

if (@ComputerDetails is not null) begin
	insert Insight.OnlineTestComputerDetails (AdministrationID,OnlineTestID,ComputerDetails)
	select @AdministrationID,@OnlineTestID,cast(@ComputerDetails as nvarchar(max));
end;

insert Document.TestTicketStatus (AdministrationID,DocumentID,StatusTime,Status)
select @AdministrationID,@DocumentID,@CreateDate,'Completed';

commit tran;

declare @Map varchar(50),@ContentArea varchar(50),@Description varchar(100);

select top(1) @Map=tmx.Map,@Description=tmx.Value,@ContentArea=t.ContentArea
from Core.TestEvent e
inner join Core.Document d on d.AdministrationID=e.AdministrationID and d.DocumentID=e.DocumentID
inner join Core.Student s on s.AdministrationID=e.AdministrationID and s.StudentID=d.StudentID
inner join Scoring.Tests t on t.AdministrationID=e.AdministrationID and t.Test=e.Test
inner join Scoring.TestMapExtensions tm on tm.AdministrationID=e.AdministrationID and tm.Test=e.Test and tm.Name='Level' and tm.Value=e.Level
inner join Scoring.TestMapExtensions tmx on tmx.AdministrationID=e.AdministrationID and tmx.Test=e.Test and tmx.Map=tm.Map and tmx.Name in (replace('Grade.'+s.Grade,'.0','.'),'Grade.*')
where e.AdministrationID=@AdministrationID and e.TestEventID=@TestEventID
order by case when tmx.Name='Grade.*' then 2 else 1 end;

select
	ContentArea,Description,
	(
		select [@name]=tms.ScoreLabel,[@color]=tmr.DisplayInfo,[@text]=tmr.Label
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
