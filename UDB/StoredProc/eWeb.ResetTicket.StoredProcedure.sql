USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ResetTicket]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [eWeb].[ResetTicket]
	@AdministrationID int,
	@DocumentID int

as

exec Insight.UpdateTicketStatus @AdministrationID=@AdministrationID,@DocumentID=@DocumentID,@Status='Unlocked';
GO
