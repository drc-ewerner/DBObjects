USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportingRawScoreGroupSummary]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*  *****************************************************************
    * Description:  This proc returns the ticket regeneration results as a result of updating the student's online accommodation.
	                Please refer to PBI 36521 
    *================================================================
    * Created:      
    * Developer:    Chris Hammons
    *================================================================
    * Changes:      Please refer to PBI 36136 (Change in the display of group summary - decimal to whole numbers for the following
                    Mode, Range, High Score, Low Score, 25%, 50%, 75%

    *
    * Date:         7/18/2014       
    * Developer:    Julie Cheah
    * Description:  
    *****************************************************************
*/

CREATE procedure [eWeb].[ReportingRawScoreGroupSummary]
	@AdministrationID int,
    @ContentArea varchar(50),
    @Grade varchar(2),
	@District varchar(15),
    @School varchar(15)
as
BEGIN
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

DECLARE @localAdminID INT, @localContentArea VARCHAR(50), @localGrade VARCHAR(2), @localDistrict VARCHAR(15), @localSchool VARCHAR(15)
SET @localAdminID = @AdministrationID
SET @localContentArea = @ContentArea
SET @localGrade = @Grade
SET @localDistrict = @District
SET @localSchool = @School

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

declare @ScoreSpread int
declare @NumQuestions int
declare @extName varchar(50) = 'Reporting.ScoreSpread.'+rtrim(ltrim(@localContentArea))+'.'+rtrim(ltrim(@localGrade))
select @ScoreSpread=eWeb.GetConfigExtensionValue(@localAdminID,'eWeb',@extName,'5')

create table #r (BeginNum int, EndNum int, NumScores int, ColName varchar(100));

declare @t table (Test varchar(50))
insert into @t
select Test from Scoring.Tests
where AdministrationID=@localAdminID and ContentArea=@localContentArea

declare @ns table (AdministrationID int, Test varchar(50), Level varchar(20), NumSessions int, NumQuestions int)
declare @nq table (AdministrationID int, Test varchar(50), Level varchar(20), NumQuestions int)
insert into @ns
select AdministrationID, PartTest, Level, (select count(distinct PartName)), 0 from Scoring.TestSessionTicketParts
where AdministrationID=@localAdminID and PartTest in (select Test from @t)
group by AdministrationID, PartTest, Level

if (@@ROWCOUNT=0) begin
	insert into @ns
	select f.AdministrationID, f.Test, f.Level, (select count(distinct isnull(PartName,''))), 0
	from Scoring.TestForms f
	left join Scoring.TestFormParts p on p.AdministrationID=f.AdministrationID and p.Test=f.Test and p.Level=f.Level and p.Form=f.Form
	/* the following was added because NE has ticket parts that don''t contain any OP items, causing the results to not display */
		AND EXISTS(SELECT * FROM Scoring.TestFormItems tfi
				INNER JOIN Scoring.Items i
				ON i.AdministrationID = tfi.AdministrationID AND i.Test = tfi.test AND i.ItemID = tfi.ItemID
					AND i.ItemStatus = 'OP'
				WHERE tfi.AdministrationID = p.AdministrationID AND tfi.Test = p.test AND tfi.Form = p.FormPart)
	where f.AdministrationID=@localAdminID and f.Test in (select Test from @t) and 
		  f.OnlineData is not null 
	group by f.AdministrationID, f.Test, f.Level;
		  
end;

insert into @nq
select distinct tf.AdministrationID,tf.Test,tf.Level,count(*)
from @ns n
inner join Scoring.TestForms tf on n.AdministrationID=tf.AdministrationID and n.Test=tf.Test and n.Level=tf.Level
inner join Scoring.TestFormItems tfi
on tf.AdministrationID=tfi.AdministrationID and tf.Test=tfi.Test and tf.Level=tfi.Level and tf.Form=tfi.Form
inner join Scoring.Items i
on tfi.AdministrationID=i.AdministrationID and tfi.Test=i.Test and tfi.ItemID=i.ItemID
where tf.AdministrationID=@localAdminID
	and tf.OnlineData is not null 
	and i.ItemType='MC' and i.ItemStatus='OP' and not exists 
	--and i.ItemType='MC'  and not exists 
			(select * from Scoring.TestFormParts where AdministrationID=tfi.AdministrationID and FormPart=tfi.Form)
group by tf.AdministrationID,tf.Test,tf.Level,tfi.Form;

update @ns set NumQuestions = q.NumQuestions
from @ns n
inner join @nq q on n.AdministrationID=q.AdministrationID and n.Test=q.Test and n.Level=q.Level;

with GetResponseData as (
select distinct ts.AdministrationID,ts.DistrictCode,ts.SchoolCode,tt.Test,tt.Level,l.DocumentID,l.StudentID,tt.BaseDocumentID,
	tr.ItemID,tr.Response,i.ItemStatus,id.CorrectResponse,id.MaxScore
from Core.TestSession ts
inner join TestSession.Links l on ts.AdministrationID=l.AdministrationID and ts.TestSessionID=l.TestSessionID
inner join Document.TestTicketView tt on ts.AdministrationID=tt.AdministrationID and l.DocumentID=tt.DocumentID
cross apply (select *, ROW_NUMBER() over (Partition by DocumentID order by CreateDate desc) as RowNum from
	Insight.OnlineTests t where ts.AdministrationID=t.AdministrationID and l.DocumentID=t.DocumentID) ot
inner join Insight.OnlineTestResponses tr on ts.AdministrationID=tr.AdministrationID and ot.OnlineTestID=tr.OnlineTestID
inner join Scoring.Items i on ts.AdministrationID=i.AdministrationID and tr.ItemID=i.ItemID
inner join Scoring.ItemDetails id on ts.AdministrationID=id.AdministrationID and tr.ItemID=id.ItemID
inner join @ns ns on tt.Test=ns.Test and tt.Level=ns.Level
where ts.AdministrationID=@localAdminID and ts.DistrictCode=@localDistrict and ts.SchoolCode=@localSchool and
	i.ItemType='MC' and i.ItemStatus='OP' 
	and ot.RowNum=1 and isnull(tt.NotTestedCode,'')='' and tt.Status='Completed'
),

GetStudentData as (
select rd.AdministrationID,rd.DistrictCode,rd.SchoolCode,rd.Test,rd.Level,rd.BaseDocumentID,rd.StudentID,
	count(distinct DocumentID) SessionsComplete,
	count(*) as Questions,sum(case when rd.Response = rd.CorrectResponse then 1 else 0 end) as Correct,
	round((sum(case when rd.Response = rd.CorrectResponse then rd.MaxScore else 0.0 end)/sum(rd.MaxScore))*100,0) as PercentCorrect,
	sum(case when rd.Response = rd.CorrectResponse then rd.MaxScore else 0.0 end) as RawScore
from GetResponseData rd
inner join Core.Student s on rd.AdministrationID=s.AdministrationID and rd.StudentID=s.StudentID
inner join @ns ns on rd.Test=ns.Test and rd.Level=ns.Level
where s.Grade = @localGrade or @localGrade = ''
group by rd.AdministrationID,rd.DistrictCode,rd.SchoolCode,rd.Test,rd.Level,rd.BaseDocumentID,rd.StudentID,ns.NumSessions
having count(distinct DocumentID) = ns.NumSessions
)

select * 
into #sd
from GetStudentData;

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

set @sql='set transaction isolation level read uncommitted; select * from #w cross join 
		  ( select numscores, colname from #r) x pivot (max(numscores) for colname in ('+@cols+')) p '

exec(@sql)

drop table #sd
drop table #r
drop table #w


END
GO
