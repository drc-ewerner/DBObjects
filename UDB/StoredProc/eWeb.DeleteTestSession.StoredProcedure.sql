USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteTestSession]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[DeleteTestSession]
	@AdministrationID int,
	@TestSessionID int
as

set nocount on;
delete Core.TestSession
where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID and not exists(
	select * from TestSession.Links k inner join Document.TestTicketView t on t.AdministrationID=k.AdministrationID and t.DocumentID=k.DocumentID
	where k.AdministrationID=@AdministrationID and k.TestSessionID=@TestSessionID and t.Status!='Not Started'
);
select TestSessionID=case when @@rowcount=0 then null else @TestSessionID end
GO
