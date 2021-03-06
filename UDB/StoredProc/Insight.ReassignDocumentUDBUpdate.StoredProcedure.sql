USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[ReassignDocumentUDBUpdate]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [Insight].[ReassignDocumentUDBUpdate]
	@AdministrationID int,
	@DocumentID int,
	@StudentID int
as
set xact_abort on; set nocount on;

declare @UserName varchar(20)

exec Insight.GetStudentUsername @AdministrationID, @StudentID, @UserName output;

begin tran

update Core.Document
set StudentID = @StudentID
where AdministrationID = @AdministrationID
and DocumentID = @DocumentID;

update dt
set UserName = @UserName
from Document.TestTicket dt
where dt.AdministrationID = @AdministrationID
and dt.DocumentID = @DocumentID;

commit tran;
GO
