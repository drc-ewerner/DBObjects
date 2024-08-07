USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteTestTicket]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[DeleteTestTicket]
	@AdministrationID int,
	@TestSessionID int,
	@StudentID int
WITH RECOMPILE 
AS

/* 8/31/2010 - Version 1.0 */
/* 1/13/2011 - Version 1.1 */
/* 5/04/2011 - Version 1.2 */
/* 10/04/2017 - Version 1.3 */
/* These should be cascaded and foreign keyed */


BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--always delete the ticket
DELETE tt
FROM Document.TestTicket tt
INNER JOIN Core.Document d ON d.AdministrationID=tt.AdministrationID AND d.DocumentID=tt.DocumentID
INNER JOIN TestSession.Links lnk ON lnk.AdministrationID=d.AdministrationID and lnk.DocumentID=d.DocumentID
WHERE tt.AdministrationID=@AdministrationID
	AND lnk.StudentID=@StudentID
	AND lnk.TestSessionID=@TestSessionID;

--optionally delete the Document
--WITH [tsl] AS
--(
--	SELECT
--		[DocumentID]
--	FROM
--		[TestSession].[Links]
--	WHERE
--		[AdministrationID] = @AdministrationID AND
--		[TestSessionID] = @TestSessionID AND
--		[StudentID] = @StudentID
--)

----From previously selected, delete those that:
--	--a) do not have associated Test Events;
--	--b) do not have a DocumentLabelCode
--DELETE [d]
--	FROM [Core].[Document] [d]
--	INNER JOIN [tsl] ON [tsl].[DocumentID] = [d].[DocumentID]
--WHERE
--	[d].[AdministrationID] = @AdministrationID AND
--	[d].[DocumentLabelCode] IS NULL AND
--	NOT EXISTS (SELECT [DocumentID]
--		FROM [Core].[TestEvent] [te]
--		WHERE
--			[te].[AdministrationID] = @AdministrationID AND
--			[te].[DocumentID] = [tsl].[DocumentID])
END

--always delete the test session link
DELETE lnk
FROM TestSession.Links lnk 
WHERE lnk.AdministrationID=@AdministrationID
AND lnk.StudentID=@StudentID
and lnk.TestSessionID=@TestSessionID;
GO
