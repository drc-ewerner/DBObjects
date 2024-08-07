USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestSessionSubTestLevels]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [eWeb].[GetTestSessionSubTestLevels]
	@AdminID INT
AS
BEGIN
	;WITH cts AS 
	(
		SELECT 
			  ct.AdministrationID
			, ct.Test
			, ct.[Level]
			, ct.SubTest
			, COUNT(*) AS SubLevelCount
		FROM Scoring.TestSessionSubTestLevels ct
		WHERE ct.AdministrationID = @AdminID
		GROUP BY 
			  ct.AdministrationID
			, ct.Test
			, ct.[Level]
			, ct.SubTest
	)
	SELECT DISTINCT
		  stl.AdministrationID
		, stl.Test
		, stl.[Level]
		, stl.[SubTest]
		, stl.[SubLevel]
		, stl.LevelMatchGroup
		, t.[Description] AS [TestDescription]
		, t.ContentArea
		, subt.[Description] AS [SubTestDescription]
		, tl.[Description] AS [SubTestLevelDescription]
		, stl.DisplayOrderTest
		, stl.DisplayOrderSubTest
		, stl.DisplayOrderSubLevel
		, stl.PreSelect
		, stl.AllowMultipleLevelsEnforceSingular
		, cts.SubLevelCount
		, tl.OptionalProcessing
	FROM Scoring.TestSessionSubTestLevels stl
	INNER JOIN cts	
		ON cts.AdministrationID = stl.AdministrationID
			AND cts.Level = stl.Level
			AND cts.SubTest = stl.SubTest
			AND cts.Test = stl.Test
	INNER JOIN Scoring.Tests t
		ON t.AdministrationID = stl.AdministrationID
			AND t.Test = stl.Test
	INNER JOIN Scoring.Tests subt
		ON subt.AdministrationID = stl.AdministrationID
			AND subt.Test = stl.SubTest
	INNER JOIN Scoring.TestLevels tl
		ON tl.AdministrationID = stl.AdministrationID
			AND tl.Test = stl.SubTest
			AND tl.[Level] = stl.SubLevel
	WHERE stl.AdministrationID = @AdminID
END
GO
