USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[DeleteTestSession]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Insight].[DeleteTestSession]
	@AdministrationID int,
	@TestSessionID int
as

set nocount on; set transaction isolation level read uncommitted;
delete Core.TestSession
where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID and not exists(
	select * from TestSession.Links k inner join Document.TestTicketView t on t.AdministrationID=k.AdministrationID and t.DocumentID=k.DocumentID
	where k.AdministrationID=@AdministrationID and k.TestSessionID=@TestSessionID and t.Status!='Not Started'
);
select TestSessionID=case when @@rowcount=0 then null else @TestSessionID end
GO
