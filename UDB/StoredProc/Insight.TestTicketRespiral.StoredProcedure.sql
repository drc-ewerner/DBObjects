USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketRespiral]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[TestTicketRespiral]
	@AdministrationID int,
	@DocumentID int
with recompile
as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare 
	@_AdministrationID int,
	@Test varchar(50),
	@Level varchar(20),
	@Form varchar(20),
	@Username varchar(50),
	@CountScores int,
	@ScoresNeeded int,
	@StudentID int,
	@NewFormNeededCount int=0,
	@Spiraled int,
	@Grade varchar(2),
	@TestSessionID int,
	@ContMultModule char(1),
	@AnyDomainTermination int,
	@TerminatedTest varchar(50),
	@CatCoefficient varchar(50),
	@CatTierPlacement varchar(50),
	@CatTierPlacementCut varchar(50),
	@UseAbility char(1)

create table #f (AdministrationID int,
				  Test varchar(50),
				  Level varchar(20),
				  Form varchar(20),
				  Type char(1),
				  DocumentID int,
				  TestEventID int,
				  ScaleScore decimal(10,5),
				  PerformanceLevel varchar(20),
				  NewForm varchar(20),
				  TierPerfLevelForm varchar(20),
				  ScoreLevel decimal(10,5),
				  Spiraled int,
				  PlaceholderForm varchar(20),
				  Grade varchar(2),
				  Cut decimal(10,5), 
				  StudentCut float,
				  Score varchar(50),
				  Tier varchar(50),
				  RawScore decimal(10,5),
				  CATTier varchar(50),
				  FourthItem varchar(50),
				  CATPath varchar(50),
				  SubmitMethod varchar(20),
				  ItemsAnswered int,
				  IEPStudent char(1),
				  DomainTermination char(1),
				  Ability decimal(10,5))

declare @SpiraledOut table (n int not null,Test varchar(50),Level varchar(20),Tier varchar(50));

set @_AdministrationID=@AdministrationID

select @ContMultModule=Value
from Config.Extensions
where AdministrationID=@AdministrationID and Category='Insight' and Name='ContinuousMultiModule' and Value='Y';

select @UseAbility=Value
from Config.Extensions
where AdministrationID=@AdministrationID and Category='Insight' and Name='UseAbilityForScaleScoreAdjustment' and Value='Y';

select @Test=t.Test,@Level=t.Level,@Username=t.UserName,@TestSessionID=l.TestSessionID
from Document.TestTicket t
inner join TestSession.Links l on t.AdministrationID=l.AdministrationID and t.DocumentID=l.DocumentID
where t.AdministrationID=@AdministrationID and t.DocumentID=@DocumentID

insert #f (Test,Level,Type,AdministrationID,DomainTermination,IEPStudent)
select Name,Value,'R',@AdministrationID,'N','N'
from Scoring.TestFormGradeExtensions tle
where tle.AdministrationID=@AdministrationID and tle.Test=@Test and tle.Level=@Level and tle.Category='AssociateWith'

update #f set Type='D',PlaceholderForm=f.Form
from #f at 
inner join Scoring.TestForms f on f.AdministrationID=@AdministrationID and f.Test=at.Test and f.Level=at.Level
	and f.SpiralingOption='Placeholder'

update #f set Form=t.Form,
			  DocumentID=t.DocumentID,
			  Spiraled=t.Spiraled
from #f at 
inner join Document.TestTicket t on t.AdministrationID=@AdministrationID and t.Test=at.Test and t.Level=at.Level
	and t.UserName=@Username
inner join TestSession.Links l on t.AdministrationID=l.AdministrationID and t.DocumentID=l.DocumentID
where @ContMultModule is null or l.TestSessionID=@TestSessionID

delete #f where DocumentID is null and Type='D'

update #f set Score=e.Score
from #f f
inner join Scoring.TestScoreExtensions e on e.AdministrationID=@AdministrationID and e.Test=f.Test and
	e.Name='SpiralingScoreSet' and e.Value='Y'

update #f set TestEventID=te.TestEventID,ScaleScore=ts.ScaleScore,Ability=case when @UseAbility='Y' then ts.Ability else 0.0 end
from #f f
inner join Core.TestEvent te on te.AdministrationID=@_AdministrationID and te.DocumentID=f.DocumentID
inner join TestEvent.TestScores ts on te.AdministrationID=ts.AdministrationID and te.TestEventID=ts.TestEventID and ts.Score=f.Score--'ALL'

select @CountScores=sum(case when Type='R' and ScaleScore is not null then 1 else 0 end),
	   @ScoresNeeded=sum(case when Type='R' then 1 else 0 end)
from #f

if @CountScores < @ScoresNeeded return;

select @StudentID=StudentID
from Core.Document d
where d.AdministrationID=@AdministrationID and d.DocumentID=@DocumentID

select @Grade=Grade
from Core.Student s
where s.AdministrationID=@AdministrationID and s.StudentID=@StudentID

--new code to adjust the scale score for low and high raw scores
select its.AdministrationID,its.Test,its.TestEventID,its.ItemID,its.Position,its.TestPosition
into #p
from #f f
cross apply (
	select 
	its.AdministrationID,its.Test,its.TestEventID,its.ItemID,its.Position,
	TestPosition=row_number() over (partition by its.AdministrationID, its.TestEventID order by its.Position)
	from TestEvent.ItemScores its
	inner join Scoring.Items i on its.AdministrationID=i.AdministrationID and its.Test=i.Test and its.ItemID=i.ItemID
	where its.AdministrationID=@_AdministrationID and its.Test=f.Test and its.TestEventID=f.TestEventID and i.ItemStatus='OP'
) its;

update #f set FourthItem=
	(select p.ItemID
	 from #p p
     where p.AdministrationID=#f.AdministrationID and p.TestEventID =#f.TestEventID and 
		p.TestPosition=4)

update #f set CATPath=e.Value
from #f f
inner join Scoring.ItemExtensions e on f.AdministrationID=e.AdministrationID and f.Test=e.Test and f.FourthItem=e.ItemID
	and 'ItemTier'=e.Name

update #f set ScaleScore=a.FinalScaleScore
from #f f
inner join Scoring.CATScaleScoreAdjustments a on a.AdministrationID=f.AdministrationID and a.Test=f.Test and a.Level=f.Level and
	a.CATPath=f.CATPath and a.Grade=@Grade and a.PrelimScaleScore=f.ScaleScore and a.PrelimAbility=f.Ability
--end of new code to adjust scale scores

--new code to determine if both CAT scores should be used in tier spiraling
update #f set SubmitMethod=ot.Method,ItemsAnswered=x.NumAttempted,DomainTermination=case when ot.Method='Manual' and x.NumAttempted=0 then 'Y' else 'N' end
from #f f
inner join Insight.OnlineTests ot on ot.AdministrationID=f.AdministrationID and ot.DocumentID=f.DocumentID
cross apply (select sum(Attempt) NumAttempted from Insight.OnlineTestItemScores otis where otis.AdministrationID=ot.AdministrationID and otis.OnlineTestID=ot.OnlineTestID) x
where ot.AdministrationID=@AdministrationID and f.Type='R'

update #f set IEPStudent=Value
from #f f
cross apply (select Value from Student.Extensions e where e.AdministrationID=@AdministrationID and StudentID=@StudentID and Category='Demographic' and Name='IEPStatus' and Value='Y')x
where f.AdministrationID=@AdministrationID and f.DomainTermination='Y'

select @AnyDomainTermination=count(*),@TerminatedTest=max(Test) from #f where DomainTermination='Y' and IEPStudent='Y'

if @AnyDomainTermination!=1 begin
	set @CatCoefficient='Coefficient'
	set @CatTierPlacement='TierPlacement'
	set @CatTierPlacementCut='TierPlacement.Cut'
end else if @AnyDomainTermination=1 and @TerminatedTest='Reading' begin
	set @CatCoefficient='Coefficient.ListeningOnly'
	set @CatTierPlacement='TierPlacement.ListeningOnly'
	set @CatTierPlacementCut='TierPlacement.Cut.ListeningOnly'
end else if @AnyDomainTermination=1 and @TerminatedTest='Listening' begin
	set @CatCoefficient='Coefficient.ReadingOnly'
	set @CatTierPlacement='TierPlacement.ReadingOnly'
	set @CatTierPlacementCut='TierPlacement.Cut.ReadingOnly'
end		
--end of code to determine if both CAT scores should be used in tier spiraling

declare @t table (Test varchar(50), 
				  Level varchar(20), 
				  CATTest varchar(50), 
				  CATLevel varchar(20),
				  CATForm varchar(20), 
				  StudentScaleScore decimal(10,5), 
				  StudentPerformanceLevel varchar(20),
				  Coefficient decimal(10,5),
				  Ans float,
				  Constant decimal(10,5),
				  StudentCut decimal(10,5),
				  TierPerfLevelCutoff varchar(20),
				  TierPerfLevelForm varchar(20),
				  Score varchar(50),
				  DomainTermination char(1))

insert @t (Test,Level,CATTest,CATLevel,CATForm,Score,StudentScaleScore,DomainTermination)
select f.Test,f.Level,x.Test,x.Level,x.Form,x.Score,x.ScaleScore,x.DomainTermination
from #f f
outer apply (select Test,Level,Form,Score,ScaleScore,case when @AnyDomainTermination=2 then 'N' else DomainTermination end DomainTermination from #f where Type='R') x
where Type='D'

update @t set TierPerfLevelCutoff=e.PerfLevel,TierPerfLevelForm=e.Form
from @t t
cross apply (select Form,Value as PerfLevel from Scoring.TestFormGradeExtensions where AdministrationID=@AdministrationID and Test=t.Test and Level=t.Level and
				Category='PerfLevel' and t.CATTest=Name) e

update @t set StudentPerformanceLevel=p.PerformanceLevel
from @t t
inner join Scoring.TestFormScorePerformanceLevels p on p.AdministrationID=@AdministrationID and p.Test=t.CATTest and
	p.Level=t.CATLevel and p.Form=t.CATForm and p.Score=t.Score and p.grade=@Grade
where t.StudentScaleScore>=p.ScaleScoreLow and t.StudentScaleScore<=p.ScaleScoreHigh

update @t set TierPerfLevelForm=null
where cast(StudentPerformanceLevel as decimal(10,5))>=cast(TierPerfLevelCutoff as decimal(10,5))

update @t set TierPerfLevelForm=null
from @t t
inner join (select Test,Level,
				CountScores=sum(case when TierPerfLevelForm is not null then 1 else 0 end),
				ScoresNeeded=sum(case when TierPerfLevelCutoff is not null then 1 else 0 end)
			from @t
			group by Test, Level) p 
	on t.Test=p.Test and t.Level=p.Level
where p.CountScores<>p.ScoresNeeded

update @t set Coefficient=e.Coefficient,Ans=e.Coefficient*(StudentScaleScore-100)
from @t t
cross apply (select Value as Coefficient from Scoring.TestFormGradeExtensions where AdministrationID=@AdministrationID and Test=t.Test and Level=t.Level and
				Grade=@Grade and Category=@CatCoefficient and Name=t.CATTest) e

update @t set Constant=e.Constant
from @t t
cross apply (select Value as Constant from Scoring.TestFormGradeExtensions where AdministrationID=@AdministrationID and Test=t.Test and Level=t.Level and
				Grade=@Grade and Category=@CatTierPlacement and Name='Constant') e

update @t set StudentCut=a.StudentCut 
from @t t
cross apply (select 1/(1+exp(-(sum(Ans)+max(Constant)))) as StudentCut, Test, Level from @t where t.Test=Test and t.Level=Level
				group by Test,Level) a

update #f set StudentCut=round(a.StudentCut,4,1),TierPerfLevelForm=a.TierPerfLevelForm,NewForm=a.TierPerfLevelForm,
	Spiraled=case when a.TierPerfLevelForm is null then Spiraled else -3 end 
from #f f
cross apply (select 1/(1+exp(-(sum(Ans)+max(Constant)))) as StudentCut, Test, Level, TierPerfLevelForm from @t where f.Test=Test and f.Level=Level
				group by Test,Level,TierPerfLevelForm) a
where f.Form=f.PlaceholderForm

update #f set Cut=cast(e.Value as decimal(10,5))
from #f f
cross apply (select top 1 Form,Value from Scoring.TestFormGradeExtensions where AdministrationID=@AdministrationID and Test=f.Test and 
	Level=f.Level and Grade=@Grade and Category=@CatTierPlacementCut and f.StudentCut <= CAST(Value as decimal(10,5)) order by Value asc) e

update #f set Tier=e.Name
from #f xx
inner join Scoring.TestFormGradeExtensions e on e.AdministrationID=@AdministrationID and e.Test=xx.Test and e.Level=xx.Level and
	e.Grade=@Grade and e.Category=@CatTierPlacementCut and cast(e.Value as decimal(10,5))=xx.Cut
inner join Scoring.TestForms f on f.AdministrationID=e.AdministrationID and f.Test=e.Test and f.Level=e.Level and f.Form=e.Form
where xx.Type='D' and xx.NewForm is null and xx.Form=xx.PlaceholderForm and xx.TierPerfLevelForm is null

select @NewFormNeededCount=count(*)
from #f
where Type='D' and NewForm is null and (Form = PlaceholderForm or DocumentID is null) and TierPerfLevelForm is null

if (@NewFormNeededCount > 0) begin
	insert @SpiraledOut select rand(checksum(newid()))*10000000+1,Test,Level,Tier
	from #f s 
	where s.Type='D' and s.NewForm is null and (s.Form=s.PlaceholderForm or s.DocumentID is null) 
		and TierPerfLevelForm is null
	select @Spiraled=n from @SpiraledOut;
with q as (
	select e.Test,e.Level,xx.Tier,e.Form,
		n=coalesce(w.SpiralNumber,row_number() over (partition by e.Test,e.Level,xx.Tier order by e.Form))-1,
		t=count(*) over (partition by e.Test,e.Level,xx.Tier)
	from #f xx 
	inner join Scoring.TestFormGradeExtensions e on e.AdministrationID=@AdministrationID and e.Test=xx.Test and e.Level=xx.Level and
		e.Grade=@Grade and e.Category=@CatTierPlacementCut and e.Name=xx.Tier and cast(e.Value as decimal(10,5))=xx.Cut
	left join Scoring.TestFormWeightedSpiraling w on w.AdministrationID=@AdministrationID and xx.Test=w.Test and xx.Level=w.Level and xx.Form=w.Form
	where xx.Type='D' and xx.NewForm is null and (xx.Form = xx.PlaceholderForm or xx.DocumentID is null) and xx.TierPerfLevelForm is null
)
update #f set NewForm=q.Form,Spiraled=s.n
from q q
inner join @SpiraledOut s on q.Test=s.Test and q.Level=s.Level and q.Tier=s.Tier
inner join #f f on f.Test=q.Test and f.Level=q.Level and f.Tier=q.Tier
where q.n=((s.n-1)%q.t) and f.NewForm is null and (f.Form=f.PlaceholderForm or f.DocumentID is null)
end;

update Document.TestTicket set Form=f.NewForm,Spiraled=f.Spiraled
from Document.TestTicket t
inner join #f f on t.AdministrationID=@AdministrationID and t.DocumentID=f.DocumentID
where f.NewForm is not null

drop table #f
drop table #p
GO
