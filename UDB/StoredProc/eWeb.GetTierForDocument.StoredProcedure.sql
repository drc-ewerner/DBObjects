USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTierForDocument]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [eWeb].[GetTierForDocument](@AdminID INT, @DocumentID INT) AS
BEGIN
	;WITH ext AS (
		SELECT DISTINCT 
			  ge.Category
			, CASE
				WHEN ge.Category = 'PerfLevel' THEN ''
				ELSE ge.Name
			  END AS Name
			  , tt.Test
		FROM Document.TestTicket tt
		LEFT JOIN Scoring.TestFormGradeExtensions ge
			ON ge.AdministrationID = tt.AdministrationID
				AND ge.Test = tt.Test
				AND ge.[Level] = tt.[Level]
				AND ge.Form = tt.Form
				AND ge.Category IN ('PerfLevel', 'TierPlacement.Cut')
		WHERE tt.AdministrationID = @AdminID AND tt.DocumentID = @DocumentID
	)
	SELECT
		Test,
		CASE
			WHEN Category = 'PerfLevel' THEN 'Pre-A'
			WHEN Category = 'TierPlacement.Cut' THEN Name
			ELSE ''
		END AS Tier
	FROM ext
END
GO
