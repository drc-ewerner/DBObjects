USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketCreate_FromRegistration]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[TestTicketCreate_FromRegistration]
  @AdministrationID int,
  @TestSessionID int,
  @StudentID int,
  @Form varchar(20)=null,
  @Test varchar(50),
  @Level varchar(20),
  @Password varchar(20)=null,
  @RegistrationID varchar(100)=null,
  @AssessmentID varchar(100)=null
as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @Username varchar(50),@Spiraled int,@FormSeq int;
declare @docs table(DocumentID int not null);
declare @r table(n int identity not null,DocumentID int not null);
declare @Parts table(n int identity not null,PartName varchar(50),PartTest varchar(50),PartLevel varchar(50));
declare @BaseDocumentID int;
declare @DiffPWBySession as bit=0,@NumParts int=1;
declare @pwd table(n int not null,Password varchar(20) not null);

select @DiffPWBySession=case when Insight.GetConfigExtensionValue(@AdministrationID,'Insight','DifferentPasswordsBySession','N')='Y' then 1 else 0 end

exec Insight.GetStudentUsername @AdministrationID,@StudentID,@Username output;

insert @Parts (PartName,PartTest,PartLevel)
select distinct PartName,f.Test,f.Level
from Scoring.TestForms f
left join Scoring.TestFormParts p on p.AdministrationID=f.AdministrationID and p.Test=f.Test and p.Level=f.Level and p.Form=f.Form
where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and f.OnlineData is not null and f.SpiralingOption is null;

select @NumParts=count(*) from @Parts;

insert @pwd (n,Password)
select n,isnull(@Password,Password) from Insight.GeneratePassword2(@AdministrationID,@Username,@NumParts);

update @pwd set Password=(select Password from @pwd where n=1)
where n>1 and @DiffPWBySession=0;

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

if (@Form is not null) begin  

  set @Spiraled=-1

end else begin
  
  select @Spiraled=@StudentID/2+1;

  with q as (
    select f.Form,n=coalesce(w.SpiralNumber,row_number() over (partition by f.Test,f.Level order by f.Form))-1,t=count(*) over ()
    from Scoring.TestForms f
    left join Scoring.TestFormWeightedSpiraling w on f.AdministrationID=w.AdministrationID and f.Test=w.Test and f.Level=w.Level and f.Form=w.Form
    where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and OnlineData is not null and SpiralingOption is null
  )
  select @Form=Form,@FormSeq=n
  from q
  where n=(@Spiraled-1)%t;

  set @Spiraled=@FormSeq;
end;

  
if (@NumParts>1) begin

  set @BaseDocumentID=next value for Core.Document_SeqEven;

  insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
  select @AdministrationID,@BaseDocumentID,@StudentID,'99'+right('0000000000'+cast(@BaseDocumentID as varchar),10);

end;		

insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
output inserted.DocumentID into @docs
select @AdministrationID,next value for Core.Document_SeqEven,@StudentID,'99'+right('0000000000'+cast((next value for Core.Document_SeqEven) as varchar),10)
from @Parts;

insert @r (DocumentID)
select DocumentID from @docs
order by DocumentID;

insert Document.TestTicket (AdministrationID,DocumentID,Test,Level,Form,UserName,Password,Spiraled,PartName,BaseDocumentID,RegistrationID,AssessmentID)
select @AdministrationID,DocumentID=r.DocumentID,Test=p.PartTest,Level=p.PartLevel,Form=@Form+isnull('.'+p.PartName,''),@Username,Password,@Spiraled,PartName=p.PartName,@BaseDocumentID,@RegistrationID,@AssessmentID
from @r r
inner join @Parts p on p.n=r.n
inner join @pwd w on w.n=r.n;

insert TestSession.Links (AdministrationID,TestSessionID,StudentID,DocumentID)
select @AdministrationID,@TestSessionID,@StudentID,DocumentID
from @r;

select documentId from @r;
GO
