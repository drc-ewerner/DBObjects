USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketRegenerate]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Insight].[TestTicketRegenerate]
	@AdministrationID int,
    @DocumentID int,
	@UserID uniqueidentifier=null,
	@ActionUserName nvarchar(256)=null,
	@CalledFrom varchar(50)=null

as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @StudentID int,@NewDocumentID int,@UserName varchar(50),@Password varchar(20),@Test varchar(50),@Level varchar(20),@Form varchar(20),@StartTime datetime,@Spiraled int,@TestSessionID int,@Offset int,@PartName varchar(50),@OldForm varchar(20),@BreachForm varchar(20),@BaseDocumentID int;
declare @NotSpiral varchar(1000),@ExcludeForm varchar(20),@TicketTest varchar(50),@TicketLevel varchar(20);

declare @ts table (DocumentID int,StatusTime datetime,Status varchar(20));
declare @a table (Name varchar(50) not null);
declare @d table (n int identity,DocumentID int,StartTime datetime,EndTime datetime,StillValid varchar(10));
declare @ad table (DocumentID int);
declare @SpiraledOut table (n int not null);
--declare @NoFixedForms as bit=1;
declare @DiffPWBySession as bit=0,@NumParts int=1,@SinglePassword varchar(20);
declare @SpecialPasswordMode as varchar(100);
declare @pwd table (n int identity,DocumentID int,Password varchar(20));
declare @temppwd table(n int not null,Password varchar(20) not null);
declare @NumStarted int=0;
declare @NumPrevComp int=0;
declare @NumTotalParts int=0;
declare @SpiralMethod varchar(1000);  --new code
declare @ActionInfo xml=null;
declare @string varchar(100);
declare @np table (DocumentID int);

if (@CalledFrom is not null) begin
set @string = 
'<actionInfo>
	<info>'+@CalledFrom+'</info>
</actionInfo>';
	set @ActionInfo = CONVERT(XML, @string, 1)
end;

select @NotSpiral=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','RegenerateOption','NULL')
if @NotSpiral='NULL' set @NotSpiral=NULL

select @DiffPWBySession=case when Insight.GetConfigExtensionValue(@AdministrationID,'Insight','DifferentPasswordsBySession','N')='Y' then 1 else 0 end

select @SpecialPasswordMode=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','SpecialPasswordMode','');

--new code
select @SpiralMethod=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','SpiralingMethod','')

select @UserName=UserName,@Test=Test,@Level=Level,@StartTime=StartTime,@Spiraled=Spiraled,@PartName=PartName,@OldForm=Form,
	@Password=Password,@TicketTest=Test,@TicketLevel=Level,@BaseDocumentID=BaseDocumentID
from Document.TestTicketView
where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

----new if statement
--if (@SpiralMethod='UsePlaceholder' and @StartTime is not null) begin
--	declare @HasPlaceholder bit=0
--	select @HasPlaceholder=1
--	from Scoring.TestForms where AdministrationID=@AdministrationID and Test=@Test and Level=@Level and 
--		SpiralingOption='Placeholder'

--	if @HasPlaceholder=0 begin
--		exec Insight.TestTicketRegenerateRespiraledTickets @AdministrationID, @DocumentID, @Test, @Level, @UserName
--	end;
--end;

select @StudentID=StudentID,@TestSessionID=TestSessionID from TestSession.Links where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

--select @NoFixedForms=0 from Scoring.TestForms where AdministrationID=@AdministrationID and Test=@Test and Level=@Level and 
--	Format='Fixed' and OnlineData is not null 

select distinct @Test=Test,@Level=Level
from Scoring.TestSessionTicketParts
where AdministrationID=@AdministrationID and PartTest=@Test and PartLevel=@Level;

if (@DiffPWBySession=1 and @BaseDocumentID is null) set @DiffPWBySession=0;

if (@DiffPWBySession=1 or @BaseDocumentID is not null) begin
	insert @d (DocumentID,StartTime,EndTime,StillValid)
	select t.DocumentID,StartTime,EndTime,case when l.AdministrationID is not null then 'Yes' else 'No' end
	from Document.TestTicketView t
	left join TestSession.Links l on l.AdministrationID=t.AdministrationID and l.DocumentID=t.DocumentID
	where t.AdministrationID=@AdministrationID and UserName=@UserName and BaseDocumentID=@BaseDocumentID --and
		--(NotTestedCode is null or NotTestedCode<>'Regenerated');
end else begin
	insert @d (DocumentID,StartTime,EndTime,StillValid)
	select t.DocumentID,StartTime,EndTime,case when l.AdministrationID is not null then 'Yes' else 'No' end
	from Document.TestTicketView t
	left join TestSession.Links l on l.AdministrationID=t.AdministrationID and l.DocumentID=t.DocumentID
	where t.AdministrationID=@AdministrationID and UserName=@UserName and Password=@Password
		and t.Test=@TicketTest and t.Level=@TicketLevel;
end;

select @NumParts=count(*) from @d where StillValid='Yes';
select @NumStarted=count(*) from @d where StartTime is not null and StillValid='Yes';
select @NumPrevComp=count(*) from @d where EndTime is not null and StillValid='No';
select @NumTotalParts=count(*) from @d;

if (@NumParts>1 and @NumStarted>0) or (@NumParts>1 and @NumPrevComp>0) begin
	set @NotSpiral='DoNotSpiral'
end;

if (@NotSpiral='SpiralIfNotStarted') begin
	set @NotSpiral=case when @NumStarted=0 then null else 'DoNotSpiral' end
end;

delete @d where StillValid='No';

if (@DiffPWBySession=0) begin
	insert @np
	select t.DocumentID
	from Document.TestTicketView t
	inner join TestSession.Links l on l.AdministrationID=t.AdministrationID and l.DocumentID=t.DocumentID
	where t.AdministrationID=@AdministrationID and UserName=@UserName and Password=@Password and
	t.DocumentID not in (select DocumentID from @d);
end;

select top(1) @ExcludeForm=p.Form 
from Scoring.TestFormParts p
where p.AdministrationID=@AdministrationID and p.Test=@Test and p.Level=@Level and p.FormPart=@OldForm;

if (@ExcludeForm is null) set @ExcludeForm=@OldForm;

select top(1) @BreachForm=Form
from Scoring.TestForms
where AdministrationID=@AdministrationID and Test=@Test and Level=@Level and Form=@ExcludeForm and SpiralingOption='Breach'

if (@NotSpiral is null) begin

	insert @a (Name)
	select Name
	from Student.Extensions
	where AdministrationID=@AdministrationID and StudentID=@StudentID and Category=(select ContentArea from Scoring.Tests where AdministrationID=@AdministrationID and Test=@Test) and Value='Y';

	insert @a (Name)
	select Name
	from Student.Extensions
	where AdministrationID=@AdministrationID and StudentID=@StudentID and Category in (select t.ContentArea from Scoring.TestSessionTicketParts p join Scoring.Tests t on t.AdministrationID=p.AdministrationID and t.Test=p.PartTest where p.AdministrationID=@AdministrationID and p.Test=@Test) and Value='Y';

	select top(1) @Form=f.Form
	from Scoring.TestAccommodationForms f
	inner join Scoring.TestForms t on t.AdministrationID=f.AdministrationID and t.Test=f.Test and t.Level=f.Level and t.Form=f.Form
	inner join @a a on a.Name=f.AccommodationName
	where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and (t.SpiralingOption is null or t.SpiralingOption!='Breach')
	order by f.FormRule, f.Form, f.AccommodationName;

	if (@Form is not null) set @Spiraled=-1;
		
	if ((@Spiraled=-1) and (@Form is null)) begin
		merge Admin.AssessmentSpirals t
		using (select @AdministrationID,@Test,@Level) s(AdministrationID,Test,Level) on (t.AdministrationID=s.AdministrationID and t.Test=s.Test and t.Level=s.Level)
		when matched then update set SpiralNumber+=1
		when not matched then insert (AdministrationID,Test,Level,SpiralNumber) values (AdministrationID,Test,Level,1)
		output inserted.SpiralNumber into @SpiraledOut;

		select @Spiraled=n from @SpiraledOut;
		
		with q as (
			select f.Form,n=coalesce(w.SpiralNumber,row_number() over (partition by f.Test,f.Level order by f.Form))-1,t=count(*) over ()
			from Scoring.TestForms f
			left join Scoring.TestFormWeightedSpiraling w on f.AdministrationID=w.AdministrationID and f.Test=w.Test and f.Level=w.Level and f.Form=w.Form
			where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and OnlineData is not null and SpiralingOption is null --and (Format='Fixed' or @NoFixedForms=1)
		)
		select @Form=Form
		from q
		where n=((@Spiraled-1)%t);

	end;

end;

--DRC-152765
--adding check for SpecialPasswordMode to match Insight.TestTicketCreate functionality
if @SpecialPasswordMode='Initials-Test' begin
  insert @temppwd
  select n,left(FirstName,1)+left(LastName,1)+'-'+@Test
  from Core.Student
  join Aux.Numbers on n between 1 and @NumParts
  where AdministrationID=@AdministrationID and StudentID=@StudentID;
end else begin
  insert @temppwd
  select * from Insight.GeneratePassword2(@AdministrationID,@Username,@NumTotalParts);
end;

insert @pwd (Password)
select Password from @temppwd


if (@DiffPWBySession=0) begin
	set @SinglePassword=(select top(1) Password from @pwd)
	update @pwd set Password=@SinglePassword
end;

update @pwd set DocumentID=d.DocumentID
from @pwd p
inner join @d d on p.n=d.n;

delete @pwd where DocumentID is null;

if (@DiffPWBySession=1 and @Form is null) begin
	delete @pwd where DocumentID<>@DocumentID
end;

if ((@StartTime is null) and (@BreachForm is null)) begin

	begin tran
		if (@NotSpiral is null) begin
			update Document.TestTicket set Password=p.Password
			from Document.TestTicket tt
			inner join @pwd p on tt.DocumentID=p.DocumentID
			where AdministrationID=@AdministrationID and tt.DocumentID in 
				(select DocumentID from @d where StartTime is not null);

			update Document.TestTicket set Password=p.Password,Form=case when @Form is null then Form else @Form+isnull('.'+PartName,'') end,Spiraled=@Spiraled
			from Document.TestTicket tt
			inner join @pwd p on tt.DocumentID=p.DocumentID
			where AdministrationID=@AdministrationID and tt.DocumentID in 
				(select DocumentID from @d where StartTime is null);
		end else begin
			update Document.TestTicket set Password=p.Password
			from Document.TestTicket tt
			inner join @pwd p on tt.DocumentID=p.DocumentID
			where AdministrationID=@AdministrationID and tt.DocumentID in (select DocumentID from @d);
		end;

		insert Document.TestTicketStatus (AdministrationID,DocumentID,Status)
		select @AdministrationID,DocumentID,'Regenerated.Password'
		from @d;

		insert Document.ActionLog (AdministrationID, DocumentID, ActionType, UserID, UserName, ActionInfo)
		select @AdministrationID,DocumentID,'Regenerated.Password',@UserID,@ActionUserName,@ActionInfo
		from @d;

		if ((select count(*) from @np) > 0) begin
			update Document.TestTicket set Password=@SinglePassword
			from Document.TestTicket tt
			inner join @np p on tt.DocumentID=p.DocumentID
			where AdministrationID=@AdministrationID;

			insert Document.TestTicketStatus (AdministrationID,DocumentID,Status)
			select @AdministrationID,DocumentID,'Regenerated.Password'
			from @np;

			insert Document.ActionLog (AdministrationID, DocumentID, ActionType, UserID, UserName, ActionInfo)
			select @AdministrationID,DocumentID,'Regenerated.Password',@UserID,@ActionUserName,@ActionInfo
			from @np;
		end;

	commit tran
	
	select DocumentID=@DocumentID;

	return;

end;

begin tran

	--new if statement
	if (@SpiralMethod='UsePlaceholder' and @StartTime is not null) begin
		declare @HasPlaceholder bit=0
		select @HasPlaceholder=1
		from Scoring.TestForms where AdministrationID=@AdministrationID and Test=@Test and Level=@Level and 
			SpiralingOption='Placeholder'

		if @HasPlaceholder=0 begin
			exec Insight.TestTicketRegenerateRespiraledTickets @AdministrationID, @DocumentID, @Test, @Level, @UserName, @UserID, @ActionUserName
		end;
	end;

	update Document.TestTicket set NotTestedCode='Regenerated'--,BaseDocumentID=null
	where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

	insert Document.TestTicketStatus (AdministrationID,DocumentID,Status)
	select @AdministrationID,@DocumentID,'Regenerated.Ticket';

	insert Document.ActionLog (AdministrationID, DocumentID, ActionType, UserID, UserName,ActionInfo)
	select @AdministrationID,@DocumentID,'Regenerated.Ticket',@UserID,@ActionUserName,@ActionInfo;

	if (@NotSpiral is null) begin
		insert @ad (DocumentID)
		select distinct t.DocumentID
		from Document.TestTicket t 
		where t.AdministrationID=@AdministrationID and t.Test=@Test and t.Level=@Level and t.UserName=@UserName 
	end else begin
		insert @ad (DocumentID)
		select @DocumentID;
	end;

	insert @ts (DocumentID,StatusTime,Status)
	select DocumentID,StatusTime,Status from Document.TestTicketStatus where AdministrationID=@AdministrationID and 
		DocumentID in (select DocumentID from @ad) and Status in ('Regenerated.Ticket','Regenerated.Password');

	delete TestSession.Links where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

	set @NewDocumentID=next value for Core.Document_SeqEven;
	update @pwd set DocumentID=@NewDocumentID where DocumentID=@DocumentID;

	insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
	select @AdministrationID,@NewDocumentID,@StudentID,'99'+right('0000000000'+cast(@NewDocumentID as varchar),10);

	if (@NotSpiral is null) begin

		select @Offset=(select count(*) from (select count(*) c from @ts 
			where Status='Regenerated.Ticket' group by Status,StatusTime)x);

		if (@Form is null) begin
			with q as (
				select f.Form,n=coalesce(w.SpiralNumber,row_number() over (partition by f.Test,f.Level order by f.Form))-1,t=count(*) over ()
				from Scoring.TestForms f
				left join Scoring.TestFormWeightedSpiraling w on f.AdministrationID=w.AdministrationID and f.Test=w.Test and f.Level=w.Level and f.Form=w.Form
				where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and OnlineData is not null and SpiralingOption is null --and (Format='Fixed' or @NoFixedForms=1)
			)
			select @Form=Form
			from q
			where n=((@Spiraled+@Offset-1)%t);
		end;
		insert Document.TestTicket (AdministrationID,DocumentID,Test,Level,Form,UserName,Password,Spiraled,PartName,BaseDocumentID)
		select @AdministrationID,@NewDocumentID,@TicketTest,@TicketLevel,@Form+isnull('.'+@PartName,''),@Username,Password,@Spiraled,@PartName,@BaseDocumentID
		from @pwd where DocumentID=@NewDocumentID
	
	end else begin

		insert Document.TestTicket (AdministrationID,DocumentID,Test,Level,Form,UserName,Password,Spiraled,PartName,BaseDocumentID)
		select @AdministrationID,@NewDocumentID,@TicketTest,@TicketLevel,@OldForm,@Username,Password,@Spiraled,@PartName,@BaseDocumentID
		from @pwd where DocumentID=@NewDocumentID

	end;

	insert Document.TestTicketStatus (AdministrationID,DocumentID,StatusTime,Status)
	select distinct @AdministrationID,@NewDocumentID,StatusTime,Status
	from @ts
	where DocumentID=@DocumentID;

	insert Document.Extensions (AdministrationID,DocumentID,Name,Value)
	select @AdministrationID,@DocumentID,'RegeneratedToDocumentID',@NewDocumentID union all
	select @AdministrationID,@NewDocumentID,'RegeneratedFromDocumentID',@DocumentID;

	insert TestSession.Links (AdministrationID,TestSessionID,StudentID,DocumentID)
	select @AdministrationID,@TestSessionID,@StudentID,@NewDocumentID;

---------------------------------------------------------------------------------------------------------

	if (@NotSpiral is null) begin	
	
		update Document.TestTicket set Password=p.Password
		from Document.TestTicket tt
		inner join @pwd p on tt.DocumentID=p.DocumentID
		where AdministrationID=@AdministrationID and tt.DocumentID in 
			(select DocumentID from @d where StartTime is not null and DocumentID!=@DocumentID);

		update Document.TestTicket set Password=p.Password,Form=isnull(@Form+'.'+PartName,Form),Spiraled=@Spiraled
		from Document.TestTicket tt
		inner join @pwd p on tt.DocumentID=p.DocumentID
		where AdministrationID=@AdministrationID and tt.DocumentID in 
			(select DocumentID from @d where StartTime is null and DocumentID!=@DocumentID);
	
	end else begin

		update Document.TestTicket set Password=p.Password
		from Document.TestTicket tt
		inner join @pwd p on tt.DocumentID=p.DocumentID
		where AdministrationID=@AdministrationID and tt.DocumentID in 
			(select DocumentID from @d where DocumentID!=@DocumentID);

	end;
	
	insert Document.TestTicketStatus (AdministrationID,DocumentID,Status)
	select @AdministrationID,DocumentID,'Regenerated.Password'
	from @d
	where DocumentID!=@DocumentID;

	insert Document.ActionLog (AdministrationID, DocumentID, ActionType, UserID, UserName,ActionInfo)
	select @AdministrationID,DocumentID,'Regenerated.Password',@UserID,@ActionUserName,@ActionInfo
	from @d
	where DocumentID!=@DocumentID;

	if ((select count(*) from @np) > 0) begin
		update Document.TestTicket set Password=@SinglePassword
		from Document.TestTicket tt
		inner join @np p on tt.DocumentID=p.DocumentID
		where AdministrationID=@AdministrationID;

		insert Document.TestTicketStatus (AdministrationID,DocumentID,Status)
		select @AdministrationID,DocumentID,'Regenerated.Password'
		from @np;

		insert Document.ActionLog (AdministrationID, DocumentID, ActionType, UserID, UserName, ActionInfo)
		select @AdministrationID,DocumentID,'Regenerated.Password',@UserID,@ActionUserName,@ActionInfo
		from @np;
	end;
				
commit tran

select DocumentID=@NewDocumentID;

return;
GO
