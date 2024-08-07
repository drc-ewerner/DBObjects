USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetTicketsByTestSession]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [Insight].[GetTicketsByTestSession] 
	@AdministrationId INT,
	@TestSessionId INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SELECT
		c.StateStudentID,
		c.Grade,
		a.userName,
		a.Password
	FROM
		Document.TestTicket a
		INNER JOIN TestSession.Links b ON a.AdministrationID = b.AdministrationID AND a.DocumentID = b.DocumentID
		INNER JOIN Core.Student c ON b.AdministrationID = c.AdministrationID AND b.StudentID=c.StudentID
	WHERE
		a.AdministrationID = @AdministrationId
		AND b.TestSessionID = @TestSessionId
END
GO
