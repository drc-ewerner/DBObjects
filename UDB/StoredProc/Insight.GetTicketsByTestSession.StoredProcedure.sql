USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetTicketsByTestSession]    Script Date: 1/12/2022 1:30:39 PM ******/
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
