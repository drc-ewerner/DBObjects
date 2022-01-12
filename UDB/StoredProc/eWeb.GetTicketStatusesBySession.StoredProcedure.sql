USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTicketStatusesBySession]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [eWeb].[GetTicketStatusesBySession](@AdminID INT, @TestSessionID INT) AS
BEGIN
SELECT cd.AdministrationID
	, cd.StudentID
	, v.Test
	, v.[Status]
	, COUNT(*) AS StatusCount
FROM Core.TestSession ts
INNER JOIN TestSession.Links tl	
	ON tl.AdministrationID = ts.AdministrationID AND tl.TestSessionID = ts.TestSessionID
INNER JOIN Core.Document cd
	ON cd.AdministrationID = tl.AdministrationID AND cd.StudentID = tl.StudentID
INNER JOIN Document.TestTicketView v
	ON v.AdministrationID = cd.AdministrationID AND v.DocumentID = cd.DocumentID
INNER JOIN TestSession.Links chk
	ON chk.AdministrationID = v.AdministrationID AND chk.DocumentID = v.DocumentID
WHERE ts.AdministrationID = @AdminID AND ts.TestSessionID = @TestSessionID
GROUP BY cd.AdministrationID
	, cd.StudentID
	, v.Test
	, v.[Status]

END

GO
