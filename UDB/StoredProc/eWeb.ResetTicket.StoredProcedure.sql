USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ResetTicket]    Script Date: 7/2/2024 9:21:54 AM ******/
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
