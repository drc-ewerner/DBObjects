USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[UnlockTestTicket]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[UnlockTestTicket]
	@AdministrationID int,
	@DocumentID int,
	@UserID uniqueidentifier=null,
	@ActionUserName nvarchar(256)=null

as

begin tran

exec Insight.UpdateTicketStatus @AdministrationID=@AdministrationID,@DocumentID=@DocumentID,@Status='Unlocked';

insert Document.ActionLog (AdministrationID, DocumentID, ActionType, UserID, UserName)
select @AdministrationID,@DocumentID,'Unlocked',@UserID,@ActionUserName
commit tran
GO
