USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[FixAccommodatedTicket]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create procedure [eWeb].[FixAccommodatedTicket]
	@AdministrationID int,
	@DocumentID int

as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare
	@TestSessionID int,
	@StudentID int,
	@Username varchar(50),
	@Password varchar(50),
	@Test varchar(20),
	@Level varchar(20),
	@PartName varchar(50),
	@Form varchar(20),
	@ContentArea varchar(50),
	@Started int
;

declare @d table (
	DocumentID int not null,
	Form varchar(20),
	PartName varchar(50),
	Started int
);	

declare @a table (Name varchar(50)  not null);

declare @aforms table (Form varchar(20) not null);

select @Username=Username,@Password=Password,@Test=Test,@Level=Level
from Document.TestTicket
where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

with d as (
	select DocumentID,Form,PartName,Started=max(case Status when 'Not Started' then 0 when 'In Progress' then 1 else 2 end) over (partition by AdministrationID,UserName,Password)
	from Document.TestTicketView
	where AdministrationID=@AdministrationID and Username=@Username and Password=@Password
)
insert @d (DocumentID,Form,PartName,Started)
select DocumentID,Form,PartName,Started
from d;

if (@@rowcount=0) return;

select @StudentID=StudentID from Core.Document where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

select @TestSessionID=TestSessionID from TestSession.Links where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

select @ContentArea=ContentArea from Scoring.Tests where AdministrationID=@AdministrationID and Test=@Test;

select top(1) @Form=Form,@PartName=PartName,@Started=Started from @d;

if (@PartName is not null) select @Form=Form from Scoring.TestFormParts where AdministrationID=@AdministrationID and Test=@Test and Level=@Level and FormPart=@Form;

insert @a (Name)
select Name from Student.Extensions where AdministrationID=@AdministrationID and StudentID=@StudentID and Category=@ContentArea and Value='Y';

insert @aforms (Form)
select f.Form
from Scoring.TestAccommodationForms f
inner join Scoring.TestForms t on t.AdministrationID=f.AdministrationID and t.Test=f.Test and t.Level=f.Level and t.Form=f.Form
inner join @a a on a.Name=f.AccommodationName
where f.AdministrationID=@AdministrationID and f.Test=@Test and f.Level=@Level and (t.SpiralingOption is null or t.SpiralingOption!='Breach');

if ((not exists(select * from @aforms)) or (@Form in (select * from @aforms))) return;

begin tran

	if (@Started=0) begin
		
		select top(1) @Form=Form from @aforms;
		
		update Document.TestTicket set Form=@Form+isnull('.'+PartName,''),Spiraled=-1
		where AdministrationID=@AdministrationID and DocumentID in (select DocumentID from @d);	
		
	end else begin

		delete Core.Document where AdministrationID=@AdministrationID and DocumentID in (select DocumentID from @d);

		delete @d;

		insert @d (DocumentID)
		exec eWeb.CreateTestTicket 	@AdministrationID=@AdministrationID,@TestSessionID=@TestSessionID,@StudentID=@StudentID,@Form=null,@MaxAssessmentsPerSite=999,@Test=@Test,@Level=@Level;

		update Document.TestTicket set Password=@Password
		where AdministrationID=@AdministrationID and DocumentID in (select DocumentID from @d);

	end;

commit tran;

select DisplayName AS Name
from @a                          a
join XRef.StudentExtensionNames  n  ON  @AdministrationID = n.AdministrationID
                                    AND @ContentArea      = n.Category
                                    AND a.Name            = n.Name
;
GO
