USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentDetailV2]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetStudentDetailV2]
	@administrationID INT,
	@studentId INT

AS

DECLARE @copyAdministrationID INT = @administrationID
DECLARE @copyStudentId INT = @studentId
/* NOTE: The eDIRECT code uses "multiResult.GetResult(Of <type>)()" which requires that the
         Property Name in eDIRECT code match up with the Column/Field Name returned by the SPROC */

--student
SELECT
	[stud].[LastName],
	[stud].[FirstName],
	[stud].[MiddleName],
	[stud].[BirthDate],
	[stud].[Gender],
	[stud].[Grade],
	[stud].[StateStudentID],
	[stud].[DistrictStudentID],
	[stud].[SchoolStudentID],
	[stud].[VendorStudentID],
	[stud].[DistrictCode],
	[stud].[SchoolCode]
FROM
	[Core].[Student] [stud]
WHERE
	[stud].[StudentId] = @copyStudentId and
	[stud].[AdministrationID] = @copyAdministrationID

--Friendly Student Attributes by Category
select ext.Category,
	isnull(names.DisplayName, ext.Name) As Name,
	isnull(vals.DisplayValue, ext.Value) as Value
from Student.Extensions ext
	LEFT OUTER JOIN XRef.StudentExtensionNames names ON names.AdministrationID=ext.AdministrationID
		AND names.Category=ext.Category and names.Name=ext.Name
	LEFT OUTER JOIN XRef.StudentExtensionValues vals ON vals.AdministrationID=ext.AdministrationID
		AND vals.Category=ext.Category and vals.Name=ext.Name
		AND vals.Value=ext.Value
where ext.AdministrationID=@copyAdministrationID
and ext.StudentID=@copyStudentId
and (isnull(ext.Value, '') <> '' or isnull(DisplayValue,'') <> '')
order by ext.Category, Name

declare @assessmentKeys table (
	DocumentID int NOT NULL,
	TestEventID int NOT NULL,
	Test varchar(50),
	TestSessionDocumentID int
)

insert @assessmentKeys(DocumentId, TestEventId, Test, TestSessionDocumentID)
select
	doc.DocumentID, te.TestEventID, te.Test, isnull(ts.DocumentID,doc.DocumentID)
from Core.Document doc
	--test event
	INNER JOIN Core.TestEvent te ON te.AdministrationID=doc.AdministrationID
		AND te.DocumentId=doc.DocumentID
	outer apply (select top 1 DocumentID from Document.TestTicket t where t.AdministrationID=doc.AdministrationID and 
		t.BaseDocumentID=doc.DocumentID) ts
where doc.AdministrationID=@copyAdministrationID
and doc.StudentID=@copyStudentId

--Test Assessments
select
	[keys].[TestEventID],
	[keys].[DocumentId],
	[te].[Test],
	[tl].[Level],
	[t].[ContentArea],
	case when isnull(tl.Description, '') = '' then [te].[Test] else [tl].[Description] end as AssessmentName,
	[te].[Form] as FormName,
	[doc].[BatchNumber] as BatchNbr,
	[doc].[SerialNumber] as SerialNbr,
	[doc].[SecurityCode],
	[doc].[Lithocode],
	[doc].[Priority] AS ProcessingPriority,
	[doc].[DocumentLabelCode],
	cast(case isnull(ts.Mode, '') when '' then 'Paper' else Mode end as varchar(10)) AS Mode,
	--cast(case isnull(doc.Lithocode, '') when '' then 'Online' else 'Paper' end as varchar(10)) AS Mode,
	cast(1 as bit) AS Operational,
	ScoringStatus = case when nonmcitems=0 then 'Multiple Choice Loaded: Y' WHEN nonmcitems!=nonmcscored then 'Multiple Choice Loaded: Y, Hand Scored Loaded: N' else 'Multiple Choice Loaded: Y, Hand Scored Loaded: Y' end
from @assessmentKeys keys
	inner join Core.TestEvent te ON te.AdministrationID=@copyAdministrationID and te.DocumentId=keys.DocumentID and te.TestEventID=keys.TestEventID and te.Test=keys.Test
	inner join Core.Document doc ON te.AdministrationID=doc.AdministrationID and doc.DocumentID=te.DocumentID
	inner join Scoring.Tests t ON te.AdministrationID=t.AdministrationID and t.Test=te.Test
	inner join Scoring.TestLevels tl ON te.AdministrationID=tl.AdministrationID and tl.Test=te.Test and tl.Level=te.Level
	left join TestSession.Links tsl ON doc.AdministrationID=tsl.AdministrationID and keys.TestSessionDocumentID=tsl.DocumentID
	left join Core.TestSession ts ON tsl.AdministrationID=ts.AdministrationID and tsl.TestSessionID=ts.TestSessionID
	cross apply (select nonmcitems=count(*) from Scoring.TestFormItems x inner join Scoring.Items i on i.AdministrationID=x.AdministrationID and i.Test=x.Test and i.ItemID=x.ItemID where x.AdministrationID=te.AdministrationID and x.Test=te.Test and x.Level=te.Level and x.Form=te.Form and i.ItemType!='MC') nonmcitems
	cross apply (select nonmcscored=count(distinct x.ItemID) from TestEvent.ItemScores x inner join Scoring.Items i on i.AdministrationID=x.AdministrationID and i.Test=x.Test and i.ItemID=x.ItemID where x.AdministrationID=te.AdministrationID and x.Test=te.Test and x.TestEventID=te.TestEventID and i.ItemType!='MC') nonmcscored

--doc extensions
select keys.TestEventID, keys.DocumentId, keys.Test, ext.Name AS DocExtName, ext.Value as DocExtValue
from @assessmentKeys keys
	INNER JOIN Document.Extensions ext ON ext.AdministrationId=@copyAdministrationID
		and ext.DocumentId = keys.DocumentID and isnull(ext.Value, '') <> ''
order by DocExtName

--scores
declare @scoreKeys table
(
	DocumentID int NOT NULL,
	TestEventID int NOT NULL,
	Test varchar(50),
	Score varchar(50)
)

insert @scoreKeys(DocumentId, TestEventID, Test, Score)
select keys.DocumentId, keys.TestEventID, keys.Test, scores.Score
from @assessmentKeys keys
	INNER JOIN TestEvent.TestScores scores ON scores.AdministrationID=@copyAdministrationID
		and scores.TestEventId=keys.TestEventId and scores.Test=keys.Test

select keys.TestEventID, keys.DocumentId, keys.Test,
	ISNULL(keys.Score, '') AS Score, isnull(scoreDef.Description, scores.Score) as ScoreName,
	ISNULL(CONVERT(varchar(30), scores.RawScore), '') AS RawScore, ISNULL(CONVERT(varchar(30), scores.ScaleScore), '') AS ScaleScore, ISNULL(scores.PerformanceLevel, '') AS PerformanceLevel,
	scores.AttemptedStatus, scores.ItemsAttempted
from @scoreKeys keys
	INNER JOIN TestEvent.TestScores scores ON scores.AdministrationID=@copyAdministrationID
		and scores.TestEventId=keys.TestEventId
		and scores.Test=keys.Test
		and scores.Score=keys.Score
	LEFT OUTER JOIN Scoring.TestScores scoreDef ON scoreDef.AdministrationID=scores.AdministrationID
		AND scoreDef.Test=keys.Test
		and scoreDef.Score=scores.Score

-- item scores (if config)
declare @ShowSLUItemScores int
select @ShowSLUItemScores=case when eWeb.GetConfigExtensionValue(@copyAdministrationID,'eWeb','ShowSLUItemScores','N')='Y' then 1 else 0 end

declare @itemScoreKeys table
(
	DocumentID int NOT NULL,
	TestEventID int NOT NULL,
	Test varchar(50),
	ItemID varchar(50),
	DetailID varchar(20)
)

insert @itemScoreKeys(DocumentId, TestEventID, Test, ItemID, DetailID)
select keys.DocumentId, keys.TestEventID, keys.Test, itemScores.ItemID, itemScores.DetailID
from @assessmentKeys keys
	INNER JOIN TestEvent.ItemScores itemScores ON itemScores.AdministrationID=@copyAdministrationID
		and itemScores.TestEventId=keys.TestEventId and itemScores.Test=keys.Test

select keys.TestEventID, keys.DocumentId, keys.Test,
	keys.ItemID, keys.DetailID,
	ISNULL(CONVERT(varchar(30), items.RawScore), '') AS RawScore,
	ISNULL(items.NonScoreCode, '') AS NonScoreCode
from @itemScoreKeys keys
	INNER JOIN TestEvent.ItemScores items on items.AdministrationID=@copyAdministrationID
	and items.TestEventID=keys.TestEventID
	and items.Test=keys.Test
	and items.ItemID=keys.ItemID
	and items.DetailID=keys.DetailID
where isnumeric(items.DetailID) > 0 and @ShowSLUItemScores = 1
order by items.ItemID, items.DetailID

--response strings
select keys.TestEventID, keys.DocumentId, keys.Test, keys.Score,
	[Type] AS ResponseType, ResponseString
from @scoreKeys keys
	INNER JOIN TestEvent.TestScoreStrings strings ON strings.AdministrationID=@copyAdministrationID
		and strings.TestEventId=keys.TestEventID and strings.Test=keys.Test and strings.score=keys.score

GO
