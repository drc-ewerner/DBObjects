USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[CreateTestTicket]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [Insight].[CreateTestTicket]
	@AdministrationID int,
    @TestSessionID int,
	@StudentID int
	
as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @Username as varchar(50);
declare @Password as varchar(20);
declare @Test as varchar(50);
declare @level as varchar(20);
declare @form as varchar(20);
declare @docs table(DocumentID int not null);
declare @r table(n int identity not null,DocumentID int not null);
--declare @tests table(n int identity not null,test varchar(50),level varchar(20),form varchar(20));
--declare @students table(n int identity not null,Username varchar(20),Password varchar(20));


select @Test = Test, @level=Level, @form=Form 
from [Core].[TestSession]
where AdministrationID=@AdministrationID and TestSessionID= @TestSessionID;


select @Username = Username, @Password = Password
from student.InsightUsername
where AdministrationID = @AdministrationID and StudentID = @StudentID;

begin tran
	insert Core.Document (AdministrationID,DocumentID,StudentID,Lithocode)
	output inserted.DocumentID into @docs
	select @AdministrationID,next value for Core.Document_SeqEven,@StudentID,'99'+right('0000000000'+cast((next value for Core.Document_SeqEven) as varchar),10)
	

	insert @r (DocumentID)
	select DocumentID from @docs
	order by DocumentID;

	insert Document.TestTicket (AdministrationID,DocumentID,Test,Level,Form,Username,Password)
	select @AdministrationID,DocumentID=r.DocumentID,@test,@level,@form,@Username,@Password
	from @r r;
	


	insert TestSession.Links (AdministrationID,TestSessionID,StudentID,DocumentID)
	select @AdministrationID,@TestSessionID,@StudentID,DocumentID
	from @r;

commit tran;

select DocumentID from @r;
GO
