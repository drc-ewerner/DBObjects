USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketCreate_SubTestLevel]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[TestTicketCreate_SubTestLevel]
	@AdministrationID int,
    @TestSessionID int,
	@StudentIDs xml,
    @MaxAssessmentsPerSite int

as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @students table (AdministrationID int, StudentID int, UserName varchar(50), Password varchar(20))
declare @makeTickets table (AdministrationID int, StudentID int, Test varchar(50), Level varchar(20), OptionalProcessing varchar(30),Password varchar(20),UserName varchar(50),DisplayOrder int)
declare @mode varchar(50),@password varchar(20)

insert @students (AdministrationID, StudentID)
select AdministrationID=@AdministrationID,d.student.value('.','int')
from @StudentIDs.nodes('//ArrayOfString/string') d(student)

select @mode=Mode from Core.TestSession where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID

if @mode!='Proctored' begin
	declare @sql varchar(max)='';

	select @sql='declare @Username varchar(50);'+char(13)
	select @sql=@sql+'exec Insight.GetStudentUsername ' + cast(AdministrationID as varchar) + ',' + cast(StudentID as varchar) + ',@Username;'
	from @students
	exec(@sql);

	update @students set UserName=u.Username
	from @students s
	inner join Student.InsightUsername u on u.AdministrationID=s.AdministrationID and u.StudentID=s.StudentID;

	update @students set Password=(select Password from Insight.GeneratePassword2(@AdministrationID,Username,1));
end else begin
	select @password=Password from Config.GenericPassword where AdministrationID=@AdministrationID and getdate() between EffectiveBeginDate and EffectiveEndDate;
	update @students set Password=@password;
end

insert @makeTickets
select @AdministrationID, s.StudentID, ts.Test,ts.Level,tl.OptionalProcessing, s.Password, s.UserName, 0
from Core.TestSession ts
inner join Scoring.TestLevels tl on tl.AdministrationID=ts.AdministrationID and tl.Test=ts.Test and tl.Level=ts.Level 
cross join @students s
where ts.AdministrationID=@AdministrationID and ts.TestSessionID=@TestSessionID and ISNULL(tl.OptionalProcessing,'')='PickFormSession'

if (@@ROWCOUNT=0) begin
	insert @makeTickets
	select @AdministrationID, s.StudentID, stl.SubTest,stl.SubLevel,tl.OptionalProcessing, s.Password, s.UserName, tsstl.DisplayOrderSubLevel
	from Core.TestSession ts
	inner join TestSession.SubTestLevels stl on stl.AdministrationID=ts.AdministrationID and stl.TestSessionID=ts.TestSessionID
	inner join Scoring.TestSessionSubTestLevels tsstl on tsstl.AdministrationID=ts.AdministrationID and tsstl.Test=ts.Test and tsstl.SubTest=stl.SubTest and tsstl.SubLevel=stl.SubLevel 
	inner join Scoring.TestLevels tl on tl.AdministrationID=stl.AdministrationID and tl.Test=stl.SubTest and tl.Level=stl.SubLevel 
	cross join @students s
	where ts.AdministrationID=@AdministrationID and ts.TestSessionID=@TestSessionID
end;

set @sql=''

select @sql=@sql+ 'exec Insight.TestTicketCreate ' + cast(AdministrationID as varchar) + ',' + cast(@TestSessionID as varchar) + ',' + cast(StudentID as varchar) + ',NULL,' +
	cast(@MaxAssessmentsPerSite as varchar) + ',''' + Test + ''',''' + Level + ''',''' + Password + ''',' + cast(DisplayOrder as varchar) + ' '
from @makeTickets
where isnull(OptionalProcessing,'') not in ('AutoLocator','PickFormSession')

select @sql=@sql+ 'exec Insight.TestTicketCreate_MultiModuleTests ' + cast(AdministrationID as varchar) + ',' + cast(@TestSessionID as varchar) + ',' + cast(StudentID as varchar) + ',NULL,' +
	cast(@MaxAssessmentsPerSite as varchar) + ',''' + Test + ''',''' + Level + ''',''' + Password + ''''
from @makeTickets
where isnull(OptionalProcessing,'') in ('AutoLocator','PickFormSession')
exec(@sql);

select distinct mt.AdministrationID,mt.StudentID,mt.Test,mt.Level
from @makeTickets mt
left join Document.TestTicket t on t.AdministrationID=mt.AdministrationID and t.Test=mt.Test and t.Level=mt.Level and t.UserName=mt.UserName and t.Password=mt.Password
left join TestSession.Links l on l.AdministrationID=mt.AdministrationID and l.DocumentID=t.DocumentID
where mt.AdministrationID=@AdministrationID and l.DocumentID is null and isnull(mt.OptionalProcessing,'') not in ('AutoLocator','PickFormSession')

union all

select distinct mt.AdministrationID,mt.StudentID,mt.Test,mt.Level
from @makeTickets mt
inner join Scoring.MultiModuleTicketParts tp on tp.AdministrationID=mt.AdministrationID and tp.Test=mt.Test and tp.Level=mt.Level
left join Document.TestTicket t on t.AdministrationID=mt.AdministrationID and t.Test=tp.PartTest and t.Level=tp.PartLevel and t.UserName=mt.UserName and t.Password=mt.Password
left join TestSession.Links l on l.AdministrationID=mt.AdministrationID and l.DocumentID=t.DocumentID
where mt.AdministrationID=@AdministrationID and l.DocumentID is null and isnull(mt.OptionalProcessing,'') in ('AutoLocator')

union all

select distinct mt.AdministrationID,mt.StudentID,mt.Test,mt.Level
from @makeTickets mt
inner join TestSession.SubTestLevels stl on mt.AdministrationID=stl.AdministrationID and @TestSessionID=stl.TestSessionID
--inner join Scoring.MultiModuleTicketParts tp on tp.AdministrationID=mt.AdministrationID and tp.Test=mt.Test and tp.Level=mt.Level
left join Document.TestTicket t on t.AdministrationID=mt.AdministrationID and t.Test=stl.SubTest and t.Level=stl.SubLevel and t.UserName=mt.UserName and t.Password=mt.Password
left join TestSession.Links l on l.AdministrationID=mt.AdministrationID and l.DocumentID=t.DocumentID
where mt.AdministrationID=@AdministrationID and l.DocumentID is null and isnull(mt.OptionalProcessing,'') in ('PickFormSession');
GO
