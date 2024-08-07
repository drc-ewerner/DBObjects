USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketCreate_ContinuousMultiModule]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[TestTicketCreate_ContinuousMultiModule]
	@AdministrationID int,
    @TestSessionID int,
	@StudentID int,
	@Form varchar(20),
    @MaxAssessmentsPerSite int,
    @Test varchar(50),
    @Level varchar(20)

as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @Username varchar(50),@Password varchar(20),@Spiraled int;
declare @SpiralMethod varchar(1000),@FormSeq int;
declare @docs table(DocumentID int not null);
declare @r table(n int identity not null,DocumentID int not null);
declare @Parts table(n int identity not null,PartName varchar(50),PartTest varchar(50),PartLevel varchar(50),
	PlaceholderForm varchar(20),SpiraledForm varchar(20),Spiraled int);
declare @SpiraledOut table (n int not null,Test varchar(50),Level varchar(50));
declare @isOnline as bit=0;  
declare @BaseDocumentID int;
declare @DiffPWBySession as bit=0,@NumParts int=1,@SinglePassword varchar(20);
declare @pwd table(n int not null,Password varchar(20) not null);

select @SpiralMethod=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','SpiralingMethod','')
select @DiffPWBySession=case when Insight.GetConfigExtensionValue(@AdministrationID,'Insight','DifferentPasswordsBySession','N')='Y' then 1 else 0 end

select @isOnline=1 from Core.TestSession where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID and Mode='Online';  

exec Insight.GetStudentUsername @AdministrationID,@StudentID,@Username output;

insert @Parts (PartName,PartTest,PartLevel)
select PartName,PartTest,PartLevel 
from Scoring.TestSessionTicketParts
where AdministrationID=@AdministrationID and Test=@Test and Level=@Level;

if (@@rowcount=0) begin

	insert @Parts (PartName,PartTest,PartLevel)
	select distinct PartName,f.Test,f.Level
	from Scoring.TestForms f
	left join Scoring.TestFormParts p on p.AdministrationID=f.AdministrationID and p.Test=f.Test and p.Level=f.Level and p.Form=f.Form
	where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and
		  ((@isOnline=1 and f.OnlineData is not null and f.SpiralingOption is null) or (@isOnline=0 and f.OnlineData is null and f.SpiralingOption is null));
		  
end;

select @NumParts=count(*) from @Parts;

select @MaxAssessmentsPerSite=@MaxAssessmentsPerSite * @NumParts

insert @pwd
select * from Insight.GeneratePassword2(@AdministrationID,@Username,@NumParts);

if (@DiffPWBySession=0) begin
	set @SinglePassword=(select top(1) Password from @pwd)
	update @pwd set Password=@SinglePassword
end;

--get placeholder form - new code
declare @HasPlaceholder bit=0
if (@SpiralMethod='UsePlaceholder') begin
	--select top(1) @Form=Form,@HasPlaceholder=1
	update @Parts set PlaceholderForm=Form,Spiraled=-2
	from @Parts p
	inner join Scoring.TestForms f
	on f.AdministrationID=@AdministrationID and f.Test=p.PartTest and f.Level=p.PartLevel and f.SpiralingOption='Placeholder'
	--where AdministrationID=@AdministrationID and Test=@Test and Level=@Level and SpiralingOption='Placeholder'
end;
--end of new code

--if @HasPlaceholder=0 begin  --new if statement related to placeholder code above
--	declare @a table (Name varchar(50) not null);

--	insert @a (Name)
--	select Name
--	from Student.Extensions
--	where AdministrationID=@AdministrationID and StudentID=@StudentID and Category in (select ContentArea from Scoring.Tests where AdministrationID=@AdministrationID and Test in (select PartTest from @Parts)) and Value='Y';

--	select top(1) @Form=Form
--	from Scoring.TestAccommodationForms f
--	inner join @a a on a.Name=f.AccommodationName
--	where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level
--	order by f.FormRule, f.Form, f.AccommodationName;
--end;

--if (@Form is not null or @isOnline=0) begin  
----changed code here
--	if @HasPlaceholder=1 begin
--		set @Spiraled=-2
--	end else begin
--		set @Spiraled=-1
--	end;
      
--end else begin

	if (@SpiralMethod='UseInternalStudentID') begin
		select @Spiraled=@StudentID+1;
	end else begin
		merge Admin.AssessmentSpirals t
		using (select @AdministrationID,PartTest as Test,PartLevel Level from @Parts p
			where p.PlaceholderForm is null) as
		 s(AdministrationID,Test,Level) on (t.AdministrationID=s.AdministrationID and t.Test=s.Test and t.Level=s.Level)
		when matched then update set SpiralNumber+=1
		when not matched then insert (AdministrationID,Test,Level,SpiralNumber) values (AdministrationID,Test,Level,1)
		output inserted.SpiralNumber,inserted.Test,inserted.Level into @SpiraledOut;

	end;

	with q as (
		select f.Test,f.Level,f.Form,n=coalesce(w.SpiralNumber,row_number() over (partition by f.Test,f.Level order by f.Form))-1,t=count(*) over (partition by f.Test,f.Level)
		from @Parts p
		inner join Scoring.TestForms f on f.AdministrationID=@AdministrationID and f.Test=p.PartTest and f.Level=p.PartLevel
		left join Scoring.TestFormWeightedSpiraling w on f.AdministrationID=w.AdministrationID and f.Test=w.Test and f.Level=w.Level and f.Form=w.Form
		where f.AdministrationID=@AdministrationID and f.OnlineData is not null and f. SpiralingOption is null and p.placeholderform is null --and (Format='Fixed' or @NoFixedForms=1)
	)

	update @Parts set SpiraledForm=q.Form,Spiraled=s.n
	from q q
	inner join @SpiraledOut s on q.Test =s.Test and q.Level=s.Level
	inner join @Parts p on p.PartTest=q.Test and p.PartLevel=q.Level
	where q.n=((s.n-1)%q.t);

	if (@SpiralMethod='UseInternalStudentID') begin
		select @Spiraled=@FormSeq;
	end
--end;


begin tran
	
--	declare @TestMode varchar(100)

--	set @TestMode = (select top 1 Mode
--	from Core.TestSession 
--	where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID)

--	if ((select count(*) from @Parts)>1) begin

--		set @BaseDocumentID=next value for Core.Document_SeqEven;

--		insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
--		select @AdministrationID,@BaseDocumentID,@StudentID,case when @TestMode = 'Paper' then Null else '99'+right('0000000000'+cast(@BaseDocumentID as varchar),10) end
--		where not exists(
--			select count(*)
--			from Core.TestSession w
--			inner join Core.TestSession x on x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode=w.SchoolCode and x.Test=w.Test and x.Level=w.Level
--			inner join TestSession.Links k on k.AdministrationID=w.AdministrationID and k.TestSessionID=x.TestSessionID
--			where w.AdministrationID=@AdministrationID and w.TestSessionID=@TestSessionID and k.StudentID=@StudentID
--			having count(*)>=@MaxAssessmentsPerSite
--			);

--		if @@ROWCOUNT = 0
--		begin
--			   select -1
--			   rollback tran;
--			   return
--		end
--		;

--		insert TestSession.Links (AdministrationID,TestSessionID,StudentID,DocumentID)
--		select @AdministrationID,@TestSessionID,@StudentID,@BaseDocumentID
--		from @r;
	
--	end;		

--	if @TestMode = 'Paper'
--	begin
--		insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
--		output inserted.DocumentID into @docs
--		select @AdministrationID,next value for Core.Document_SeqEven,@StudentID,Null
--		from @Parts
--		where not exists(
--			select count(*)
--			from Core.TestSession w
--			inner join Core.TestSession x on x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode=w.SchoolCode and x.Test=w.Test and x.Level=w.Level
--			inner join TestSession.Links k on k.AdministrationID=w.AdministrationID and k.TestSessionID=x.TestSessionID
--			where w.AdministrationID=@AdministrationID and w.TestSessionID=@TestSessionID and k.StudentID=@StudentID
--			having count(*)>=@MaxAssessmentsPerSite
--			);

--			if @@ROWCOUNT = 0
--			begin
--				   select -1
--				   rollback tran;
--				   return
--			end
--			;	

--	end
--	else 
--	begin
		insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
		output inserted.DocumentID into @docs
		select @AdministrationID,next value for Core.Document_SeqEven,@StudentID,'99'+right('0000000000'+cast((next value for Core.Document_SeqEven) as varchar),10)
		from @Parts
		where not exists(
			select count(*)
			from Core.TestSession w
			inner join Core.TestSession x on x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode=w.SchoolCode and x.Test=w.Test and x.Level=w.Level
			inner join TestSession.Links k on k.AdministrationID=w.AdministrationID and k.TestSessionID=x.TestSessionID
			where w.AdministrationID=@AdministrationID and w.TestSessionID=@TestSessionID and k.StudentID=@StudentID
			having count(*)>=@MaxAssessmentsPerSite
			);

			if @@ROWCOUNT = 0
			begin
				   select -1
				   rollback tran;
				   return
			end
			;
	--end	

	insert @r (DocumentID)
	select DocumentID from @docs
	order by DocumentID;

	insert Document.TestTicket (AdministrationID,DocumentID,Test,Level,Form,UserName,Password,Spiraled,BaseDocumentID)
	select @AdministrationID,DocumentID=r.DocumentID,Test=p.PartTest,Level=p.PartLevel,
		Form=coalesce(p.PlaceholderForm,p.SpiraledForm),@Username,Password,Spiraled,@BaseDocumentID
	from @r r
	inner join @Parts p on p.n=r.n
	inner join @pwd w on w.n=r.n;

	insert TestSession.Links (AdministrationID,TestSessionID,StudentID,DocumentID)
	select @AdministrationID,@TestSessionID,@StudentID,DocumentID
	from @r;

commit tran;
--new code here
--declare @DocumentID int
--select top (1) @DocumentID=DocumentID from @r
--if @HasPlaceholder=1 begin
--	exec Insight.TestTicketRespiral @AdministrationID,@DocumentID
--end;

select DocumentID from @r;
GO
