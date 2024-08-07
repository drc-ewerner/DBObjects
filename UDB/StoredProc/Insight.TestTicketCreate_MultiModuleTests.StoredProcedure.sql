USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketCreate_MultiModuleTests]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[TestTicketCreate_MultiModuleTests]
  @AdministrationID int,
  @TestSessionID int,
  @StudentID int,
  @Form varchar(20),
  @MaxAssessmentsPerSite int,
  @Test varchar(50),
  @Level varchar(20),
  @Password varchar(20)=null

as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @Username varchar(50),@Spiraled int;
declare @SpiralMethod varchar(1000),@FormSeq int;
declare @docs table(DocumentID int not null);
declare @r table(n int identity not null,DocumentID int not null);
declare @Parts table(n int identity not null,PartTest varchar(50),PartLevel varchar(50),Form varchar(20),FormPart varchar(20),PartName varchar(50),ModuleOrder int,PlaceholderForm varchar(20),SpiraledForm varchar(20),Spiraled int,GroupByTest varchar(50),GroupByLevel varchar(50));
declare @Tests table(n int identity not null,PartTest varchar(50),PartLevel varchar(50),BaseDocumentID int,ModuleOrder int,Form varchar(20))
declare @SpiraledOut table (n int not null,Test varchar(50),Level varchar(50));
declare @isOnline as bit=0;  
declare @BaseDocumentID int;
declare @DiffPWBySession as bit=0,@NumParts int=1,@SinglePassword varchar(20);
declare @pwd table(n int not null,Password varchar(20) not null);
declare @TestMode varchar(100);
declare @MultiModuleForm varchar(20);

select @SpiralMethod=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','SpiralingMethod','')
select @DiffPWBySession=case when Insight.GetConfigExtensionValue(@AdministrationID,'Insight','DifferentPasswordsBySession','N')='Y' then 1 else 0 end

set @TestMode = (select top(1) Mode	from Core.TestSession where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID);
if @TestMode in ('Online','Proctored') set @isOnline=1

if @TestMode='Proctored' begin
  exec Insight.BuildProctoredUsername @AdministrationID,@StudentID,@Username output;
end else begin
  exec Insight.GetStudentUsername @AdministrationID,@StudentID,@Username output;
end

set @MultiModuleForm=(select top(1) Form from Scoring.MultiModuleTicketParts where administrationid=@AdministrationID and test=@Test and level=@Level order by newid());

insert @Parts (PartTest,PartLevel,Form,FormPart,PartName,ModuleOrder,GroupByTest,GroupByLevel)
select PartTest,PartLevel,p.Form,FormPart,PartName,ModuleOrder,'X','X'
from Core.TestSession ts
inner join Scoring.TestLevels tl on ts.AdministrationID=tl.AdministrationID and ts.Test=tl.Test and ts.Level=tl.Level
inner join TestSession.SubTestLevels stl on stl.AdministrationID=ts.AdministrationID and stl.TestSessionID=ts.TestSessionID
inner join Scoring.MultiModuleTicketParts p on p.AdministrationID=stl.AdministrationID and p.Test=@Test and p.Level=@Level and p.PartTest=stl.SubTest and p.PartLevel=stl.SubLevel and p.Form=@MultiModuleForm
where ts.AdministrationID=@AdministrationID and ts.Test=@Test and ts.Level=@Level and tl.OptionalProcessing='PickFormSession' and ts.TestSessionID=@TestSessionID
order by ModuleOrder;

if (@@rowcount=0) begin
  insert @Parts (PartTest,PartLevel,Form,FormPart,PartName,ModuleOrder,GroupByTest,GroupByLevel)
  select PartTest,PartLevel,Form,FormPart,PartName,ModuleOrder,PartTest,PartLevel
  from Scoring.MultiModuleTicketParts
  where AdministrationID=@AdministrationID and Test=@Test and Level=@Level
  order by ModuleOrder
end;

if (@SpiralMethod='WithinTest') begin

  declare @a table (Test varchar(50) not null,Level varchar(20),Form varchar(20) not null);

  insert @a (Test,Level,Form)
  select distinct Test,Level,Form
  from Student.Extensions x
  cross apply (select Test from Scoring.Tests t where t.AdministrationID=x.AdministrationID and t.ContentArea=x.Category) t
  cross apply (select Level=PartLevel from @Parts p where p.PartTest=t.Test) p
  cross apply (select top(1) Form from Scoring.TestAccommodationForms f where f.AdministrationID=x.AdministrationID and f.Test=t.Test and f.Level=p.Level and f.AccommodationName=x.Name order by f.FormRule,f.Form,f.AccommodationName) f
  where AdministrationID=@AdministrationID and StudentID=@StudentID and Value='Y';

  with u as (
    select distinct PartTest,PartLevel,Form,NewForm=isnull(AccomForm,SpiralForm),Spiraled=AccomSpiraled
    from @parts p
    cross apply (select top(1) SpiralForm=Form from Scoring.TestForms f cross join Aux.CryptRandView where f.AdministrationID=@AdministrationID and f.Test=PartTest and f.Level=PartLevel and f.OnlineData is not null and f.SpiralingOption is null order by rand) x
    outer apply (select top(1) AccomForm=a.Form,AccomSpiraled=-1 from @a a where a.Test=PartTest and a.level=PartLevel order by a.Form) a
  )
  update p set Form=NewForm,FormPart=replace(FormPart,u.Form,NewForm),Spiraled=u.Spiraled
  from @parts p
  join u on u.PartTest=p.PartTest and u.PartLevel=p.PartLevel and u.Form=p.Form;

end;

select @NumParts=count(*) from @Parts;

select @MaxAssessmentsPerSite=@MaxAssessmentsPerSite*@NumParts;

declare @np int=@NumParts;
if @TestMode='Proctored' begin
  while @np > 0 begin
    insert @pwd
    select @np,Password from Config.GenericPassword where AdministrationID=@AdministrationID and getdate() between EffectiveBeginDate and EffectiveEndDate;
    set @np=@np-1;
  end;
end else begin
  insert @pwd
  select * from Insight.GeneratePassword2(@AdministrationID,@Username,@NumParts);
end;

if (@Password is not null) begin
  update @pwd set Password=@Password;
end;

if (@DiffPWBySession=0) begin
  set @SinglePassword=(select top(1) Password from @pwd);
  update @pwd set Password=@SinglePassword;
end;

--get placeholder form
declare @HasPlaceholder bit=0;
if (@SpiralMethod='UsePlaceholder') begin
  update @Parts set PlaceholderForm=f.Form,Spiraled=-2
  from @Parts p
  inner join Scoring.TestForms f
  on f.AdministrationID=@AdministrationID and f.Test=p.PartTest and f.Level=p.PartLevel and f.SpiralingOption='Placeholder';
end;

begin tran

  insert @Tests (PartTest,PartLevel,BaseDocumentID,ModuleOrder,Form)
  select GroupByTest,GroupByLevel,next value for Core.Document_SeqEven over (order by min(ModuleOrder)),min(ModuleOrder),Form
  from @Parts
  where PartName is not null
  group by GroupByTest,GroupByLevel,Form;

  insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
  select @AdministrationID,BaseDocumentID,@StudentID,'99'+right('0000000000'+cast(BaseDocumentID as varchar),10)
  from @Tests
  order by ModuleOrder

  insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
  output inserted.DocumentID into @docs
  select @AdministrationID,next value for Core.Document_SeqEven over (order by ModuleOrder),@StudentID,'99'+right('0000000000'+cast((next value for Core.Document_SeqEven over (order by ModuleOrder)) as varchar),10)
  from @Parts
  where not exists(
    select count(*)
    from Core.TestSession w
    inner join Core.TestSession x on x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode=w.SchoolCode and x.Test=w.Test and x.Level=w.Level
    inner join TestSession.Links k on k.AdministrationID=w.AdministrationID and k.TestSessionID=x.TestSessionID
    where w.AdministrationID=@AdministrationID and w.TestSessionID=@TestSessionID and k.StudentID=@StudentID
    having count(*)>=@MaxAssessmentsPerSite
    )
  order by ModuleOrder;

  if (@@ROWCOUNT=0) begin
    select -1;
    rollback tran;
    return;
  end;

  insert @r (DocumentID)
  select DocumentID from @docs
  order by DocumentID;

  insert Document.TestTicket (AdministrationID,DocumentID,Test,Level,Form,UserName,Password,Spiraled,PartName,BaseDocumentID,ModuleOrder)
  select @AdministrationID,DocumentID=r.DocumentID,Test=p.PartTest,Level=p.PartLevel,Form=p.FormPart,@Username,Password,case when Spiraled is null then 0 else Spiraled end,p.PartName,t.BaseDocumentID,p.ModuleOrder
  from @r r
  inner join @Parts p on p.n=r.n
  left join @Tests t on p.GroupByTest=t.PartTest and p.GroupByLevel=t.PartLevel and p.Form=t.Form
  inner join @pwd w on w.n=r.n
  order by p.ModuleOrder;

  insert TestSession.Links (AdministrationID,TestSessionID,StudentID,DocumentID)
  select @AdministrationID,@TestSessionID,@StudentID,DocumentID
  from @r;

commit tran;

select DocumentID from @r;
GO
