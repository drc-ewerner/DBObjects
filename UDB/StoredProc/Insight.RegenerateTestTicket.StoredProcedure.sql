USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[RegenerateTestTicket]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [Insight].[RegenerateTestTicket]
	@AdministrationID int,
    @DocumentID int
as
set xact_abort on; set nocount on;



declare @StudentID int
,@NewDocumentID int
,@UserName varchar(50)
,@Password varchar(20)
,@Test varchar(50)
,@Level varchar(20)
,@Form varchar(20)
,@StartTime datetime
,@Spiraled int
,@TestSessionID int
,@Offset int
,@PartName varchar(50)
,@NotTestedCode varchar(50);

declare @ts table (StatusTime datetime,Status varchar(20));

select @UserName=UserName
,@Password = Password
,@Test=Test
,@Level=Level
,@StartTime=StartTime
,@Spiraled=Spiraled
,@PartName=PartName
,@Form=Form
,@NotTestedCode = NotTestedCode
from Document.TestTicketView
where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

select @StudentID=StudentID,@TestSessionID=TestSessionID 
from TestSession.Links 
where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

if (@StartTime is not null) and isnull(@NotTestedCode,'') <> 'Regenerated'begin

begin tran

	update Document.TestTicket set NotTestedCode='Regenerated'
	where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

	insert Document.TestTicketStatus (AdministrationID,DocumentID,Status)
	select @AdministrationID,@DocumentID,'Regenerated.Ticket';

	insert @ts (StatusTime,Status)
	select StatusTime,Status 
	from Document.TestTicketStatus 
	where AdministrationID=@AdministrationID 
	and DocumentID=@DocumentID 
	and Status in ('Regenerated.Ticket');

	delete TestSession.Links where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

	set @NewDocumentID=next value for Core.Document_SeqEven;

	insert Core.Document (AdministrationID,Documentid,StudentID)
	select @AdministrationID,@NewDocumentID,@StudentID;
		
	insert Document.TestTicket (AdministrationID,DocumentID,Test,Level,Form,UserName,Password,Spiraled,PartName)
	select @AdministrationID,@NewDocumentID,@Test,@Level,@Form,@Username,@Password,@Spiraled,@PartName;

	insert Document.TestTicketStatus (AdministrationID,DocumentID,StatusTime,Status)
	select @AdministrationID,@NewDocumentID,StatusTime,Status
	from @ts;

	--do we need this??
	insert Document.Extensions (AdministrationID,DocumentID,Name,Value)
	select @AdministrationID,@DocumentID,'RegeneratedToDocumentID',@NewDocumentID union all
	select @AdministrationID,@NewDocumentID,'RegeneratedFromDocumentID',@DocumentID;

	insert TestSession.Links (AdministrationID,TestSessionID,StudentID,DocumentID)
	select @AdministrationID,@TestSessionID,@StudentID,@NewDocumentID;

commit tran

select DocumentID=@NewDocumentID;

return;
end;


select DocumentID=0;
return;
GO
