USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetExtensionForAllTickets]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [eWeb].[GetExtensionForAllTickets](
	@AdminID INT, 
	@TestSessionID INT, 
	@ExtensionCategory VARCHAR(50),
	@ExtensionName VARCHAR(50)
)
AS
BEGIN
	SELECT DISTINCT tl.AdministrationID
		, tl.StudentID
		, ISNULL(se.Value, '') AS ExtValue
	FROM TestSession.Links tl
	LEFT OUTER JOIN Student.Extensions se
		ON se.AdministrationID = tl.AdministrationID AND se.StudentID = tl.StudentID
			AND se.Category = @ExtensionCategory AND se.Name = @ExtensionName
	WHERE tl.AdministrationID = @AdminID AND tl.TestSessionID = @TestSessionID
END
GO
