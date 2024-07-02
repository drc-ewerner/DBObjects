USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateTicketNotTestedCode]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[UpdateTicketNotTestedCode]
@AdministrationID INT, @DocumentID INT, @NotTestedCode VARCHAR (2)
AS
begin
/* 8/31/2010 - Version 1.0 */
	update Document.TestTicket	
	set NotTestedCode=@NotTestedCode
	where AdministrationID=@AdministrationID and DocumentID=@DocumentID
	
end
GO
