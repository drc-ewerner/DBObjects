USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateTicketNotTestedCode]    Script Date: 1/12/2022 1:30:39 PM ******/
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
