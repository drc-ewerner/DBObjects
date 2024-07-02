USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportingRawScoreGroupSummaryEISScoresV7]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [eWeb].[ReportingRawScoreGroupSummaryEISScoresV7]
	@AdministrationID int,
    @ContentArea varchar(50),
    @Grade varchar(2),
	@District varchar(15),
    @School varchar(15),
	@AssessmentName varchar(100)
as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

Declare 
    @_AdministrationID int,
    @_ContentArea varchar(50),
    @_Grade varchar(2),
	@_District varchar(15),
    @_School varchar(15),
	@_AssessmentName varchar(100)

set @_AdministrationID = @AdministrationID 
set @_ContentArea = @ContentArea 
set @_Grade = @Grade 
set @_District = @District 
set @_School = @School 
set @_AssessmentName = @AssessmentName 	   
/*  *****************************************************************
    * Description:  This proc returns a group summary for View Online Results for MO Option 7     
	*================================================================
*/

IF object_id('tempdb..#r') is not null
begin	
	drop table #r
end

IF object_id('tempdb..#sd') is not null
begin
	drop table #sd
end

IF object_id('tempdb..#w') is not null
begin
	drop table #w
end

declare @ScoreConfig varchar(1000)=eWeb.GetConfigExtensionValue(@_AdministrationID,'eWeb','Reporting.OnlineResults.ScoreSet','N');

DECLARE @Test TABLE(Test Varchar(50) PRIMARY KEY CLUSTERED(Test))
DECLARE @Level TABLE(Level Varchar(20) PRIMARY KEY CLUSTERED(Level))

INSERT INTO @Test select distinct Test from Scoring.Tests where AdministrationID=@_AdministrationID and ContentArea=@_ContentArea
INSERT INTO @Level select distinct Level from Scoring.TestLevelGrades where AdministrationID=@_AdministrationID and Test in (select Test from @Test) and Grade=@_Grade
                                  

declare @ScoreSpread int
declare @NumQuestions int
declare @extName varchar(50) = 'Reporting.ScoreSpread.'+rtrim(ltrim(@_ContentArea))+'.'+rtrim(ltrim(@_Grade))
select @ScoreSpread=eWeb.GetConfigExtensionValue(@_AdministrationID,'eWeb',@extName,'5')

create table #r (BeginNum int, EndNum int, NumScores int, ColName varchar(100));

declare @t table (Test varchar(50))
insert into @t
select Test from Scoring.Tests
where AdministrationID=@_AdministrationID and ContentArea=@_ContentArea

declare @ns table (AdministrationID int, Test varchar(50), Level varchar(20), NumQuestions int)
insert into @ns
SELECT
	AdministrationID, Test, [Level], MaxRawScore
FROM Scoring.TestFormScores
WHERE AdministrationID = @_AdministrationID AND Test IN (SELECT Test FROM @t) AND Score = @ScoreConfig

select DISTINCT
	AdministrationID,DistrictCode,SchoolCode,RawScore=cast(RawScore as int),Questions=cast(MaxRawScore as int)  
	, cts.Test, cts.[Level], ROUND(((cast(RawScore as int) * 1.0) / cast(MaxRawScore as int)) * 100.0 , 0) AS PercentCorrect
	, StudentID, LastName
into #sd
from (select AdministrationID,TestSessionID,Test,Level,DistrictCode,SchoolCode from Core.TestSession) cts
cross apply (select StudentID,DocumentID from TestSession.Links where AdministrationID=cts.AdministrationID and TestSessionID=cts.TestSessionID) tsl
cross apply (select Grade,LastName from Core.Student where AdministrationID=cts.AdministrationID and StudentID=tsl.StudentID) cs
cross apply (select ContentArea from Scoring.Tests where AdministrationID=cts.AdministrationID and Test=cts.Test) st
outer apply (select [Description], Level FROM Scoring.TestLevels WHERE AdministrationID = cts.AdministrationID AND Test = cts.Test AND Level = cts.Level) stl
cross apply (select BaseDocumentID from Document.TestTicket where AdministrationID=cts.AdministrationID and DocumentID=tsl.DocumentID and Test=cts.Test and Level=cts.Level) dtt
cross apply (select distinct TestEventID from Core.TestEvent where AdministrationID=cts.AdministrationID and DocumentID=isnull(dtt.BaseDocumentID,tsl.DocumentID) and Test=cts.Test and Level=cts.Level) cte
cross apply (select RawScore from TestEvent.TestScores where AdministrationID=cts.AdministrationID and TestEventID=cte.TestEventID and Test=cts.Test and Score=@ScoreConfig) tets
cross apply (select cast(Value as numeric) MaxRawScore,Name from TestEvent.Extensions where AdministrationID=cts.AdministrationID and Test=cts.Test and Name='MaxRawAttempted'+@ScoreConfig and TestEventID=cte.TestEventID) tee
cross apply (select TestStatus from TestEvent.TestStatus where AdministrationID=cts.AdministrationID and TestEventID=cte.TestEventID and Test=cts.Test and ((TestStatus='AutoScoringComplete') or (TestStatus='AllScoringComplete'))) tetstat
where 
	AdministrationID=@_AdministrationID and DistrictCode=@_District and SchoolCode=@_School 	
	and cts.Test in (select Test from @Test)
    and cts.Level in (select Level from @Level) 
	and Grade=@_Grade
	and stl.Description  = @_AssessmentName

declare @d table (BeginNum int, EndNum int, NumScores int, ColName varchar(100))
declare @begin int=@ScoreSpread+1

insert @d (BeginNum, EndNum)
select 0, @ScoreSpread

set @NumQuestions=(select max(NumQuestions) from @ns ns where exists 
					(select * from #sd sd where ns.AdministrationID=sd.AdministrationID and ns.Test=sd.Test and ns.Level=sd.Level))

while @begin < @NumQuestions
  begin
	insert @d (BeginNum,EndNum)
	select @begin, case when @begin+@ScoreSpread-1 > @NumQuestions then @NumQuestions else @begin+@ScoreSpread-1 end
	set @begin=@begin+@ScoreSpread
  end

if (@begin=@NumQuestions) begin
	insert @d (BeginNum,EndNum)
	select @begin,@NumQuestions
end

update @d set ColName='Dist'+LTRIM(RTRIM(cast(BeginNum as varchar))) + 'to' +LTRIM(RTRIM(cast(EndNum as varchar)))

declare @sql varchar(max)
declare @cols varchar(max);

With CalcPercentiles as (
select distinct
	percentile_cont(0.25) within group (order by RawScore) over () as Percentile25,
	percentile_cont(0.5) within group (order by RawScore) over () as Percentile50,
	percentile_cont(0.75) within group (order by RawScore) over () as Percentile75
from #sd
),

CalcMisc as (
select count(*) as NumStudents,
	   min(RawScore) as LowScore,
	   max(RawScore) as HighScore,
	   STDEVP(RawScore) as StandardDev,
	   avg(RawScore) as Mean,
	   max(RawScore) - min(RawScore) as Range
from #sd
),

CountScores as (
select RawScore, count(*) as NumScores
from #sd
group by RawScore),

MaxScores as (
select max(NumScores) as MaxCount
from CountScores
),

CalcMode as (
select case when count(*) = 1 then cast(cast(max(RawScore) as decimal(6,0)) as varchar(8)) else 'N/A' end as Mode
from CountScores
inner join MaxScores on NumScores=MaxCount
group by NumScores
--order by count(*) desc
),

CalcMedian as (
select ((select top 1 RawScore from (select top 50 percent RawScore from #sd order by RawScore) as A
	order by RawScore desc) + (select top 1 RawScore from (select top 50 percent RawScore from #sd
	order by RawScore desc) as A order by RawScore asc)) / 2 as Median
)

select NumStudents,
	   cast(round(Mean,1) as decimal(6,1)) as Mean,
	   cast(Median as decimal(6,1)) as Median,
	   --cast(Mode as decimal(6,1)) as Mode,
	   Mode,
	   cast(round(StandardDev,1) as decimal(6,1)) as StandardDev,
	   cast(Range as decimal(6,0)) as Range,
	   cast(HighScore as decimal(6,0)) as HighScore,
	   cast(LowScore as decimal(6,0)) as LowScore,
	   cast(floor(Percentile25) as decimal(6,0)) as Percentile25,
	   cast(floor(Percentile50) as decimal(6,0)) as Percentile50,
	   cast(floor(Percentile75) as decimal(6,0)) as Percentile75
into #w
from CalcMisc,CalcMode,CalcMedian,CalcPercentiles

insert into #r
select d.BeginNum,d.EndNum, sum(case when a.RawScore is null then 0 else 1 end),d.ColName
FROM @d d
  LEFT JOIN #sd a ON a.RawScore BETWEEN d.BeginNum AND d.EndNum
GROUP BY d.BeginNum,d.EndNum,d.ColName;

set @cols=STUFF((select ','+quotename(ColName) from @d order by BeginNum for xml path(''),type 
		  ).value('.', 'nvarchar(max)'),1,1,'')

set @sql='select * from #w cross join 
		  ( select numscores, colname from #r) x pivot (max(numscores) for colname in ('+@cols+')) p '

exec(@sql)

drop table #sd
drop table #r
drop table #w

GO
