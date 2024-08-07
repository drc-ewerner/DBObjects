USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketCreate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[TestTicketCreate]
  @AdministrationID int,
  @TestSessionID int,
  @StudentID int,
  @Form varchar(20),
  @MaxAssessmentsPerSite int,
  @Test varchar(50),
  @Level varchar(20),
  @Password varchar(20)=null,
  @ModuleOrder int=null

as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @Username varchar(50),@Spiraled int;
declare @SpiralMethod varchar(1000),@FormSeq int;
declare @docs table(DocumentID int not null);
declare @r table(n int identity not null,DocumentID int not null);
declare @Parts table(n int identity not null,PartName varchar(50),PartTest varchar(50),PartLevel varchar(50));
declare @SpiraledOut table (n int not null);
declare @isOnline as bit=0;  
declare @BaseDocumentID int;
declare @DiffPWBySession as bit=0,@NumParts int=1,@SinglePassword varchar(20);
declare @SpecialPasswordMode as varchar(100);
declare @pwd table(n int not null,Password varchar(20) not null);
declare @SimplePaperTickets as bit=0;
declare @ModValue int=1;
declare @TestMode varchar(100);
declare @initTranCount int=@@trancount;


select @SpiralMethod=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','SpiralingMethod','');
select @DiffPWBySession=case when Insight.GetConfigExtensionValue(@AdministrationID,'Insight','DifferentPasswordsBySession','N')='Y' then 1 else 0 end;
select @SimplePaperTickets=case when Insight.GetConfigExtensionValue(@AdministrationID,'Insight','SimplePaperTickets','N')='Y' then 1 else 0 end;
select @SpecialPasswordMode=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','SpecialPasswordMode','');

set @TestMode = (select top(1) Mode	from Core.TestSession where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID);
if @TestMode in ('Online','Proctored') set @isOnline=1;

if (@SpiralMethod like 'ModValue.%') set @ModValue=parsename(@SpiralMethod,1);

if @TestMode='Proctored' begin
  exec Insight.BuildProctoredUsername @AdministrationID,@StudentID,@Username output;
end else begin
  exec Insight.GetStudentUsername @AdministrationID,@StudentID,@Username output;
end

insert @Parts (PartName,PartTest,PartLevel)
select PartName,PartTest,PartLevel 
from Scoring.TestSessionTicketParts
where AdministrationID=@AdministrationID and Test=@Test and Level=@Level;

if (@@rowcount=0) begin

  if ((@isOnline=0) and (@SimplePaperTickets=1)) begin

    insert @Parts (PartName,PartTest,PartLevel)
    select distinct null,f.Test,f.Level
    from Scoring.TestForms f
    where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level;

  end else begin

    insert @Parts (PartName,PartTest,PartLevel)
    select distinct PartName,f.Test,f.Level
    from Scoring.TestForms f
    left join Scoring.TestFormParts p on p.AdministrationID=f.AdministrationID and p.Test=f.Test and p.Level=f.Level and p.Form=f.Form
    where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and ((@isOnline=1 and f.OnlineData is not null and f.SpiralingOption is null) or (@isOnline=0 and f.OnlineData is null and f.SpiralingOption is null));

  end;
      
end;

select @NumParts=count(*) from @Parts;

select @MaxAssessmentsPerSite=@MaxAssessmentsPerSite * @NumParts;


if @SpecialPasswordMode='Initials-Test' begin
  select @Password=left(FirstName,1)+left(LastName,1)+'-'+@Test
  from Core.Student
  where AdministrationID=@AdministrationID and StudentID=@StudentID;
  insert @pwd select n,'' from Aux.Numbers where n between 1 and @NumParts;
end else if @TestMode='Proctored' begin
  declare @np int=@NumParts;
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

declare @HasPlaceholder bit=0;
if (@SpiralMethod='UsePlaceholder') begin
  select top(1) @Form=Form,@HasPlaceholder=1
  from Scoring.TestForms
  where AdministrationID=@AdministrationID and Test=@Test and Level=@Level and SpiralingOption='Placeholder';
end;

if @HasPlaceholder=0 begin
  declare @a table (Name varchar(50) not null);

  insert @a (Name)
  select Name
  from Student.Extensions
  where AdministrationID=@AdministrationID and StudentID=@StudentID and Category in (select ContentArea from Scoring.Tests where AdministrationID=@AdministrationID and Test in (select PartTest from @Parts)) and Value='Y';

  select top(1) @Form=f.Form
  from Scoring.TestAccommodationForms f
  inner join Scoring.TestForms t on f.AdministrationID=t.AdministrationID and f.Test=t.Test and f.Level=t.Level and f.Form=t.Form
  inner join @a a on a.Name=f.AccommodationName
  where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and (t.SpiralingOption is null or t.SpiralingOption!='Breach')
  order by f.FormRule, f.Form, f.AccommodationName;
end;

if (@Form is not null or @isOnline=0) begin  

  set @Spiraled=iif(@HasPlaceholder=1,-2,-1);
      
end else begin

  if (@SpiralMethod='UseInternalStudentID') begin
    select @Spiraled=@StudentID+1;
  end else begin
    merge Admin.AssessmentSpirals t
    using (select @AdministrationID,@Test,@Level) s(AdministrationID,Test,Level) on (t.AdministrationID=s.AdministrationID and t.Test=s.Test and t.Level=s.Level)
    when matched then update set SpiralNumber+=1
    when not matched then insert (AdministrationID,Test,Level,SpiralNumber) values (AdministrationID,Test,Level,1)
    output inserted.SpiralNumber into @SpiraledOut;
    select @Spiraled=n from @SpiraledOut;
  end;

  with q as (
    select f.Form,n=coalesce(w.SpiralNumber,row_number() over (partition by f.Test,f.Level order by f.Form))-1,t=count(*) over ()
    from Scoring.TestForms f
    left join Scoring.TestFormWeightedSpiraling w on f.AdministrationID=w.AdministrationID and f.Test=w.Test and f.Level=w.Level and f.Form=w.Form
    where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and OnlineData is not null and SpiralingOption is null --and (Format='Fixed' or @NoFixedForms=1)
  )
  select @Form=Form,@FormSeq=n
  from q
  where n=(((@Spiraled-1)/@ModValue)%t);

  if (@SpiralMethod='UseInternalStudentID') begin
    select @Spiraled=@FormSeq;
  end
end;

if (@initTranCount=0) begin tran
  
  if ((@NumParts>1) and ((@TestMode in ('Online','Proctored')) or (@SimplePaperTickets=0))) begin

    set @BaseDocumentID=next value for Core.Document_SeqEven;

    insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
    select @AdministrationID,@BaseDocumentID,@StudentID,case when @TestMode = 'Paper' then Null else '99'+right('0000000000'+cast(@BaseDocumentID as varchar),10) end
    where not exists(
      select count(*)
      from Core.TestSession w
      inner join Core.TestSession x on x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode=w.SchoolCode and x.Test=w.Test and x.Level=w.Level
      inner join TestSession.Links k on k.AdministrationID=w.AdministrationID and k.TestSessionID=x.TestSessionID
      where w.AdministrationID=@AdministrationID and w.TestSessionID=@TestSessionID and k.StudentID=@StudentID
      having count(*)>=@MaxAssessmentsPerSite
      );

    if (@@rowcount=0) begin
      select -1;
      if (@initTranCount=0) rollback tran;
      return;
    end;

    insert TestSession.Links (AdministrationID,TestSessionID,StudentID,DocumentID)
    select @AdministrationID,@TestSessionID,@StudentID,@BaseDocumentID
    from @r;
  
  end;		

  if (@TestMode='Paper') begin
    insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
    output inserted.DocumentID into @docs
    select @AdministrationID,next value for Core.Document_SeqEven,@StudentID,Null
    from @Parts
    where not exists(
      select count(*)
      from Core.TestSession w
      inner join Core.TestSession x on x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode=w.SchoolCode and x.Test=w.Test and x.Level=w.Level
      inner join TestSession.Links k on k.AdministrationID=w.AdministrationID and k.TestSessionID=x.TestSessionID
      where w.AdministrationID=@AdministrationID and w.TestSessionID=@TestSessionID and k.StudentID=@StudentID
      having count(*)>=@MaxAssessmentsPerSite
      );

    if (@@rowcount=0) begin
      select -1;
      if (@initTranCount=0) rollback tran;
      return;
    end;

  end	else begin
  
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

    if (@@rowcount=0) begin
      select -1;
      if (@initTranCount=0) rollback tran;
      return;
    end;
  
  end;

  insert @r (DocumentID)
  select DocumentID from @docs
  order by DocumentID;

  insert Document.TestTicket (AdministrationID,DocumentID,Test,Level,Form,UserName,Password,Spiraled,PartName,BaseDocumentID,ModuleOrder)
  select @AdministrationID,DocumentID=r.DocumentID,Test=p.PartTest,Level=p.PartLevel,Form=@Form+isnull('.'+p.PartName,''),@Username,Password,@Spiraled,PartName=p.PartName,@BaseDocumentID,@ModuleOrder
  from @r r
  inner join @Parts p on p.n=r.n
  inner join @pwd w on w.n=r.n;

  insert TestSession.Links (AdministrationID,TestSessionID,StudentID,DocumentID)
  select @AdministrationID,@TestSessionID,@StudentID,DocumentID
  from @r;

if (@initTranCount=0) commit tran;

declare @DocumentID int;
select top (1) @DocumentID=DocumentID from @r;
if @HasPlaceholder=1 begin
  declare @tempAdminId int;
  select @tempAdminId = t.AdministrationID from Core.TestSession t
  inner join Admin.AssessmentSchedule a on a.AdministrationID=t.AdministrationID and a.Test=t.Test and a.Level=t.Level and a.Mode=t.Mode and a.TestWindow=t.TestWindow
  where t.AdministrationID=@AdministrationID and t.TestSessionID=@TestSessionID and GETDATE() between a.StartDate and a.EndDate;
  if (@tempAdminId is not null) and (@tempAdminId > 0) begin
    exec Insight.TestTicketRespiral @AdministrationID,@DocumentID;
  end;
end;

select DocumentID from @r;
GO
