USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[TestTicketPurge]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[TestTicketPurge]
	@AdministrationID int,
    @DocumentID int
as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @UserName varchar(50),@Password varchar(20),@BaseDocumentID int,@DiffPWBySession bit=0,@TestSessionID int, @StudentID int;

declare @d table(DocumentID int)

select @DiffPWBySession=case when Insight.GetConfigExtensionValue(@AdministrationID,'Insight','DifferentPasswordsBySession','N')='Y' then 1 else 0 end

select @UserName=UserName,@Password=Password,@BaseDocumentID=BaseDocumentID,@TestSessionID=TestSessionID,@StudentID=StudentID
from Document.TestTicketView t
inner join TestSession.Links l on l.AdministrationID=t.AdministrationID and l.DocumentID=t.DocumentID
where t.AdministrationID=@AdministrationID and t.DocumentID=@DocumentID

if (@BaseDocumentID is null and @DiffPWBySession=1) set @DiffPWBySession=0

if (@DiffPWBySession=0) begin
	insert @d (DocumentID)
	select t.DocumentID
	from Document.TestTicket t
	inner join TestSession.Links l on l.AdministrationID=t.AdministrationID and l.DocumentID=t.DocumentID
	where t.AdministrationID=@AdministrationID and UserName=@UserName and Password=@Password and TestSessionID=@TestSessionID
		and StudentID=@StudentID
end else begin
	insert @d (DocumentID)
	select DocumentID
	from Document.TestTicket
	where AdministrationID=@AdministrationID and UserName=@UserName and BaseDocumentID=@BaseDocumentID
end;

begin tran

	update Document.TestTicket set NotTestedCode='Purged'
	where AdministrationID=@AdministrationID and DocumentID in (select DocumentID from @d);

	insert Document.TestTicketStatus (AdministrationID,DocumentID,Status)
	select @AdministrationID,DocumentID,'Purged'
	from @d;
	
	delete TestSession.Links where AdministrationID=@AdministrationID and DocumentID in (select DocumentID from @d); 

commit tran
GO
