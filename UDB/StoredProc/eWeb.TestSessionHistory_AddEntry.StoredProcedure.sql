USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TestSessionHistory_AddEntry]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [eWeb].[TestSessionHistory_AddEntry]
	@AdministrationID INT, @TestSessionID INT, @UserID Uniqueidentifier, @TestSessionXML XML
AS 
BEGIN
	INSERT INTO TestSession.History(AdministrationID, TestSessionID, CreateDate, UserID, [Source], TestSessionXML)
	SELECT @AdministrationID
		, @TestSessionID
		, GETDATE()
		, @UserID
		, 'eDirect'
		, @TestSessionXML
END
GO
