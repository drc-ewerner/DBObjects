USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TierAssignmentOverride]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Insight].[TierAssignmentOverride]
	@AdministrationID int,
	@DocumentID int,
	@Tier varchar(50)

as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare 
	@Test varchar(50),
	@Level varchar(20),
	@Form varchar(20),
	@StudentID int,
	@Spiraled int,
	@Grade varchar(2),
	@FoundForm char(1),
	@Status varchar(50)

declare @SpiraledOut table (n int not null,Test varchar(50),Level varchar(20),Tier varchar(50));

select @Test=t.Test,@Level=t.Level,@Status=Status,@Spiraled=Spiraled 
from Document.TestTicketView t
inner join TestSession.Links l on t.AdministrationID=l.AdministrationID and t.DocumentID=l.DocumentID
where t.AdministrationID=@AdministrationID and t.DocumentID=@DocumentID

if (@Status!='Not Started' or @Spiraled=-2) return;
set @Spiraled = null;

select @StudentID=d.StudentID, @Grade=Grade
from Core.Document d
inner join Core.Student s on d.AdministrationID=s.AdministrationID and d.StudentID=s.StudentID
where d.AdministrationID=@AdministrationID and d.DocumentID=@DocumentID

if @Tier='Pre-A' begin
	select distinct @Form=Form,@FoundForm='Y',@Spiraled=-3
	from Scoring.TestFormGradeExtensions
	where AdministrationID=@AdministrationID and Test=@Test and Level=@Level and 
		Category = 'PerfLevel' 
end

if @Tier!='Pre-A' begin
	select @FoundForm='Y'
	from Scoring.TestFormGradeExtensions
	where AdministrationID=@AdministrationID and Test=@Test and Level=@Level and Grade=@Grade and
		Category='TierPlacement.Cut' and Name=@Tier
end

if (@Tier!='Pre-A' and @FoundForm='Y') begin

	merge Admin.AssessmentSpirals t
	using (select @AdministrationID,@Test NewTest,@Level NewLevel, @Tier NewTier) as 
			s(AdministrationID, NewTest, NewLevel, NewTier)
	on t.AdministrationID=s.AdministrationID and t.Test=s.NewTest and t.Level=s.NewLevel and t.SpiralField1=s.NewTier
	when matched then update set SpiralNumber+=1
	when not matched then insert (AdministrationID,Test,Level,SpiralNumber,SpiralField1) 
		values (AdministrationID,NewTest,NewLevel,1,NewTier)
	output inserted.SpiralNumber,inserted.Test,inserted.Level,inserted.SpiralField1 into @SpiraledOut;
	select @Spiraled=n from @SpiraledOut;

	with q as (
		select e.Test,e.Level,@Tier Tier,e.Form,
			n=(row_number() over (partition by e.Test,e.Level,@Tier order by e.Form))-1,
			t=count(*) over (partition by e.Test,e.Level,@Tier)
		from Scoring.TestFormGradeExtensions e 
		inner join Scoring.TestForms f on e.AdministrationID=f.AdministrationID and e.Test=f.Test and e.Level=f.Level and e.Form=f.Form
		where e.AdministrationID=@AdministrationID and e.Test=@Test and e.Level=@Level and
			e.Grade=@Grade and e.Category='TierPlacement.Cut' and e.Name=@Tier
	)
	select @Form=q.Form,@Spiraled=s.n
	from q q
	inner join @SpiraledOut s on q.Test=s.Test and q.Level=s.Level and q.Tier=s.Tier
	where q.n=((s.n-1)%q.t) 
end;

if (@FoundForm='Y' and @Form is not null) begin
	begin tran
	update Document.TestTicket set Form=@Form,Spiraled=@Spiraled
	from Document.TestTicket t
	where t.AdministrationID=@AdministrationID and t.DocumentID=@DocumentID

	insert Document.TierOverrideLog (AdministrationID,DocumentID,Tier)
	select @AdministrationID,@DocumentID,@Tier
	commit tran
end
GO
