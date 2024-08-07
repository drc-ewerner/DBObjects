USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentCountByAssessmentSpiralForm]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetStudentCountByAssessmentSpiralForm]

@AdministrationID INT

AS
-- The command SET FMTONLY OFF ensures the correct data type is returned
-- by the auto-generated LINQ to SQL method.
-- 1. Uncomment it prior to dragging SPROC onto .dbml.
-- 2. Drag the SPROC.
-- 3. Comment the command back out.
--SET FMTONLY OFF

SELECT
	[t].[ContentArea],
	[t].[Test],
	[tl].[Level],
	'IsFieldTest' = CASE WHEN [t].[Test] LIKE 'FT_%' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
	'AssessmentText' = ISNULL([tl].[Description], [tl].[Level]),
	[ft].[HCMode],
	[ft].[HCFormName]

INTO [#Spiraling]

FROM
	[Scoring].[Tests] [t]
	INNER JOIN [Scoring].[TestLevels] [tl] ON
		[tl].[AdministrationID] = [t].[AdministrationID] AND
		[tl].[Test] = [t].[Test]
	LEFT JOIN [Scoring].[TestForms] [tf] ON
		[tf].[AdministrationID] = [t].[AdministrationID] AND
		[tf].[Test] = [t].[Test] AND
		[tf].[Level] = [tl].[Level]
	LEFT JOIN [Config].[Extensions] [ext] ON
		[ext].[AdministrationID] = [tl].[AdministrationID] AND
		[ext].[Category] = 'eWeb' AND
		[ext].[Name] = [tl].[Test] + '.' + [tl].[Level] + '.Hide'
	LEFT JOIN [Config].[Extensions] [ext1] ON
		[ext1].[AdministrationID] = [tl].[AdministrationID] AND
		[ext1].[Category] = 'eWeb' AND [ext1].[Name] = [t].[ContentArea] + '.Hide'
	CROSS JOIN (SELECT 'HCFormName' = '-', 'HCMode' = 'Paper' UNION ALL
				SELECT '01', 'Online' UNION ALL
				SELECT 'Spiraled', 'Online') AS [ft] --HC stands for 'Hard-Coded'
WHERE
	[t].[AdministrationID] = @AdministrationID AND
	[t].[ContentArea] NOT LIKE '$%' AND
	[tl].[Description] NOT LIKE '$%'
GROUP BY
	[t].[ContentArea],
	[t].[Test],
	[tl].[Level],
	[tl].[Description],
	[ft].[HCMode],
	[ft].[HCFormName]
HAVING
	MAX(ISNULL([tf].[Format], '')) <> 'CAT'

 --------- Do Combined Select
SELECT 
	[s].[ContentArea],
	[s].[Test],
	[s].[Level],
	[s].[AssessmentText],
	[s].[IsFieldTest],
	[s].[HCMode],
	[s].[HCFormName],
	'StudentCount' = ISNULL([counts].[StudentCount], 0)
FROM
	[#Spiraling] [s]
	LEFT JOIN
	(
	--Get Student Count for 'Paper' Mode
	SELECT
		[ts].[Test],
		[ts].[Level],
		[ts].[Mode],
		'StudentCount' = COUNT(DISTINCT CONVERT(VARCHAR, [l].[TestSessionID]) + '-' + CONVERT(VARCHAR, [l].[StudentID])),
		'FormName' = '-'
	FROM
		[Core].[TestSession] [ts]
		INNER JOIN [TestSession].[Links] [l] ON
			[ts].[AdministrationID] = [l].[AdministrationID] AND
			[l].[TestSessionID] = [ts].[TestSessionID]
	WHERE
		[ts].[AdministrationID] = @AdministrationID AND
		[ts].[Mode] = 'Paper'
	GROUP BY
		[ts].[Test],
		[ts].[Level],
		[ts].[Mode]
		
	UNION ALL
		
	--Select Student Count for Form '01'
	SELECT
		[ts].[Test],
		[ts].[Level],
		[ts].[Mode],
		'StudentCount' = COUNT(DISTINCT CONVERT(VARCHAR, [l].[TestSessionID]) + '-' + CONVERT(VARCHAR, [l].[StudentID])),
		'FormName' = [ext].[Value]
	FROM
		[Core].[TestSession] [ts]
		INNER JOIN [TestSession].[Links] [l] ON
			[ts].[AdministrationID] = [l].[AdministrationID] AND
			[l].[TestSessionID] = [ts].[TestSessionID]
		LEFT JOIN [Site].[Extensions] [ext] ON 
			[ext].[AdministrationID] = ISNULL([ts].[AdministrationID], 0) AND
			[ext].[DistrictCode] = ISNULL([ts].[DistrictCode], '') AND
			[ext].[SchoolCode] = ISNULL([ts].[SchoolCode], '') AND
			[ext].[Name] = ISNULL([ts].[Test] + '.' + [ts].[Level] + '.FORMNAME', '') AND
			[ext].[Category] = 'Spiral'
	WHERE
		[ts].[AdministrationID] = @AdministrationID AND
		[ts].[Mode] = 'Online' AND
		[ext].[Value] = '01'
	GROUP BY
		[ts].[Test],
		[ts].[Level],
		[ts].[Mode],
		[ext].[Value]

	UNION ALL

	-- Get Student Count For Spiraled Form
	SELECT
		[ts].[Test],
		[ts].[Level],
		[ts].[Mode],
		'StudentCount' = COUNT(DISTINCT CONVERT(VARCHAR, [l].[TestSessionID]) + '-' + CONVERT(VARCHAR, [l].[StudentID])),
		'FormName' = 'Spiraled'
	FROM
		[Core].[TestSession] [ts]
		INNER JOIN [TestSession].[Links] [l] ON
			[ts].[AdministrationID] = [l].[AdministrationID] AND
			[l].[TestSessionID] = [ts].[TestSessionID]
		LEFT JOIN [Site].[Extensions] [ext] ON 
			[ext].[AdministrationID] = ISNULL([ts].[AdministrationID], 0) AND
			[ext].[DistrictCode] = ISNULL([ts].[DistrictCode], '') AND
			[ext].[SchoolCode] = ISNULL([ts].[SchoolCode], '') AND
			[ext].[Name] = ISNULL([ts].[Test] + '.' + [ts].[Level] + '.FORMNAME', '') AND
			[ext].[Category] = 'Spiral'
	WHERE
		[ts].[AdministrationID] = @AdministrationID AND
		[ts].[Mode] = 'Online' AND
		[ext].[Value] IS NULL
	GROUP BY
		[ts].[Test],
		[ts].[Level],
		[ts].[Mode],
		[ext].[Value]
	) AS [counts] ON
		[counts].[Test] = [s].[Test] AND
		[counts].[Level] = [s].[Level] AND
		[counts].[FormName] = [s].[HCFormName]
	ORDER BY
		[s].[ContentArea],
		[s].[Test],
		[s].[Level],
		[s].[HCFormName]
GO
