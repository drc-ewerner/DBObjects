USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[UpdateTicketStatus]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[UpdateTicketStatus]
	@AdministrationID int,
	@DocumentID int,
	@Status varchar(50),
	@LocalTimeOffset varchar (10) = null,
	@Timezone varchar(5) = null
as
set nocount on; set transaction isolation level read uncommitted;

insert Document.TestTicketStatus (AdministrationID,DocumentID,Status,LocalTimeOffset,Timezone)
select @AdministrationID,@DocumentID,@Status,@LocalTimeOffset,@Timezone;
GO
