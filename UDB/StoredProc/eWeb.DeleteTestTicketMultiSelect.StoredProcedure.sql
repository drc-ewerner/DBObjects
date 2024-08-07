USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteTestTicketMultiSelect]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[DeleteTestTicketMultiSelect]
	@AdministrationID int,
	@TestSessionID int,
	@StudentIDs XML

AS

BEGIN
DECLARE @students TABLE (AdministrationID INT, StudentID INT)

INSERT INTO @students (AdministrationID, StudentID)
SELECT AdministrationID = @AdministrationID
	,d.student.value('.','int')
FROM @StudentIDs.nodes('//ArrayOfString/string') d(student)


--always delete the ticket
DELETE tt
FROM Document.TestTicket tt
INNER JOIN Core.Document d ON d.AdministrationID=tt.AdministrationID AND d.DocumentID=tt.DocumentID
INNER JOIN TestSession.Links lnk ON lnk.AdministrationID=d.AdministrationID and lnk.DocumentID=d.DocumentID
INNER JOIN @students st ON st.AdministrationID = lnk.AdministrationID AND st.StudentID = lnk.StudentID
WHERE tt.AdministrationID=@AdministrationID
and lnk.TestSessionID=@TestSessionID;

--optionally delete the Document
DECLARE @tsl TABLE(DocumentID INT PRIMARY KEY CLUSTERED (DocumentID))

INSERT INTO @tsl
SELECT [DocumentID]
FROM [TestSession].[Links] tl
INNER JOIN @students st
	ON st.AdministrationID = tl.AdministrationID AND st.StudentID = tl.StudentID
WHERE
	tl.[AdministrationID] = @AdministrationID AND
	tl.[TestSessionID] = @TestSessionID 

--From previously selected, delete those that:
	--a) do not have associated Test Events;
	--b) do not have a DocumentLabelCode
DELETE [d]
	FROM [Core].[Document] [d]
	INNER JOIN @tsl tsl ON [tsl].[DocumentID] = [d].[DocumentID]
WHERE
	[d].[AdministrationID] = @AdministrationID AND
	[d].[DocumentLabelCode] IS NULL AND
	NOT EXISTS (SELECT [DocumentID]
		FROM [Core].[TestEvent] [te]
		WHERE
			[te].[AdministrationID] = @AdministrationID AND
			[te].[DocumentID] = [tsl].[DocumentID])

--always delete the test session link
DELETE lnk
FROM TestSession.Links lnk 
INNER JOIN @students st ON st.AdministrationID = lnk.AdministrationID AND st.StudentID = lnk.StudentID
WHERE lnk.AdministrationID=@AdministrationID
and lnk.TestSessionID=@TestSessionID;

END
	
GO
