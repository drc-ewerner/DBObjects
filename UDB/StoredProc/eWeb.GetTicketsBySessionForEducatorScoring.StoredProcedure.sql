USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTicketsBySessionForEducatorScoring]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetTicketsBySessionForEducatorScoring] 

       @AdministrationID INT,
       @TestSessionID INT,
       @LastName VARCHAR (100) = null,
       @Status VARCHAR (100) = null
AS

SELECT DISTINCT
       [t].[AdministrationID],
       [t].[DocumentID],
       [t].[Test],
	   CASE
		WHEN st.TestStatus IN ('MCScoringComplete', 'AutoScoringComplete') THEN 'Ready to Score'
		WHEN st.TestStatus = 'AllScoringComplete' THEN 'Complete'
		ELSE ''
	   END AS [Status],
       [s].[StudentID],
       [s].[StateStudentID],
       [s].[FirstName],
       [s].[LastName],
       [s].[Grade],
       [ts].[TestSessionID],
	   ste.ContentArea
FROM [Core].[TestSession] [ts]
INNER JOIN Scoring.Tests ste
	ON ste.AdministrationID = ts.AdministrationID AND ste.Test = ts.Test
INNER JOIN [TestSession].[Links][k] ON
        [k].[AdministrationID] = [ts].[AdministrationID] AND
        [k].[TestSessionID] = [ts].[TestSessionID]
INNER JOIN [Document].[TestTicketView] [t] ON
        [t].[AdministrationID] = [k].[AdministrationID] AND
        [t].[DocumentID] = [k].[DocumentID]
LEFT OUTER JOIN Core.TestEvent te
	ON te.AdministrationID = t.AdministrationID
		AND te.DocumentID = COALESCE(t.BaseDocumentID, t.DocumentID)
		AND te.Test = t.Test
		AND te.[Level] = t.[Level]
LEFT OUTER JOIN TestEvent.TestStatus st
	ON st.AdministrationID = te.AdministrationID
		AND st.TestEventID = te.TestEventID
		AND st.Test = te.Test
LEFT JOIN [Core].[Student] [s] ON
        [s].[AdministrationID] = [k].[AdministrationID] AND
        [s].[StudentID] = [k].[StudentID]
WHERE
       [ts].[AdministrationID] = @AdministrationID AND
       [ts].[TestSessionID] = @TestSessionID  AND
       (ISNULL(@LastName, '') = '' OR [s].[LastName] LIKE '%' + @LastName + '%') AND
	   (
			ISNULL(@Status, '') IN ('(All)', '')
			OR (st.TestStatus = 'MCScoringComplete' AND @Status = 'Ready to Score')
			OR (st.TestStatus = 'AutoScoringComplete' AND @Status = 'Ready to Score')
			OR (st.TestStatus = 'AllScoringComplete' AND @Status = 'Complete')
	   )

ORDER BY
       t.[Test],
       [LastName],
       [FirstName]



GO
