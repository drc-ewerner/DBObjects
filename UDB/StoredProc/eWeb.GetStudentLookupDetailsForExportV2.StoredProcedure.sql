USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentLookupDetailsForExportV2]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[GetStudentLookupDetailsForExportV2] 
       @AdministrationID INT, --AdminID
       @securityCodeLike VARCHAR(15) = NULL, --ADSecurityCode
       @LastNameLike VARCHAR(100) = NULL, --Last Name
       @FirstNameLike VARCHAR(100) = NULL, --First Name
       @ProcessingPriorityLike VARCHAR(10) = NULL, --Processing Priority
       @batchNumberLike VARCHAR(30) = NULL, --Batch Number
       @serialNumberLike VARCHAR(6) = NULL,  --Serial Number
       @lithoCodeLike VARCHAR(15) = NULL, --Lithocode
       @AnyStudentIdLike VARCHAR(50) = NULL, --StudentID
       @TestLike VARCHAR(50) = NULL, --Subject
       @Grade VARCHAR(2) = NULL, --Grade
       @DistrictCode varchar(15) = NULL, --District Code
       @SchoolCode varchar(15) = NULL, --School Code
       @onlyTestedStudents int --Checkbox for tested students only
AS
DECLARE @Results TABLE
(
	AdministrationName varchar(250),
	[LastName] VARCHAR(100) NULL,
	[FirstName] VARCHAR(100) NULL, 
	[MiddleName] VARCHAR(100) NULL, 
	[DistrictCode] varchar(15),
	[SchoolCode] varchar(15),
	Grade varchar(10),
	[DistrictStudentId] VARCHAR(20) NULL,
	[VendorStudentId] VARCHAR(50) NULL,
	[SchoolStudentId] VARCHAR(20) NULL,
	[BirthDate] DATETIME NULL, 
	[Gender] VARCHAR(2) NULL, 
	[StateStudentId] VARCHAR(20) NULL,
	AssessmentName VARCHAR(100) NULL,
	FormName VARCHAR(100) NULL,
	BatchNbr VARCHAR(100) NULL,
	SerialNbr VARCHAR(100) NULL,
	SecurityCode VARCHAR(100) NULL,
	Lithocode VARCHAR(100) NULL,
	Mode VARCHAR(100) NULL,
	Precode VARCHAR(100) NULL,
	ProcessingPriority VARCHAR(100) NULL,
	ScoringStatus VARCHAR(100) NULL,
	ScoreName VARCHAR(100) NULL,
	RawScore VARCHAR(100) NULL,
	ScaleScore VARCHAR(100) NULL,
	PerformanceLevel VARCHAR(100) NULL,
	AttemptedStatus VARCHAR(100) NULL,
	ItemsAttempted VARCHAR(100) NULL,
	[StudentId] INT
)
INSERT @Results	
SELECT DISTINCT 
	s.AdministrationID ,[s].[LastName], [s].[FirstName], [s].[MiddleName], [s].[DistrictCode],[s].[SchoolCode], [s].[Grade], [s].[DistrictStudentID],
	[s].[VendorStudentID], [s].[SchoolStudentID],    [s].[BirthDate],  [s].[Gender], [s].[StateStudentID],
		case when isnull(tl.Description, '') = '' then [te].[Test] else [tl].[Description] end as AssessmentName, --Assessment HEader
	[te].[Form] as FormName, [sd].[BatchNumber] as BatchNbr, [sd].[SerialNumber] as SerialNbr, [sd].[SecurityCode],
	[sd].[Lithocode], cast(case isnull([ts].Mode, '') when '' then 'Paper' else Mode end as varchar(10)) AS Mode,
	[sd].[DocumentLabelCode] as Precode,    [sd].[Priority] AS ProcessingPriority,
	ScoringStatus = case when nonmcitems=0 then 'Multiple Choice Loaded: Y' WHEN nonmcitems!=nonmcscored then 'Multiple Choice Loaded: Y, Hand Scored Loaded: N' else 'Multiple Choice Loaded: Y, Hand Scored Loaded: Y' end,
	isnull(scoreDef.Description, scores.Score) as ScoreName,
	ISNULL(CONVERT(varchar(30), scores.RawScore), '') AS RawScore,ISNULL(CONVERT(varchar(30), scores.ScaleScore), '') AS ScaleScore,
	ISNULL(scores.PerformanceLevel, '') AS PerformanceLevel,
	scores.AttemptedStatus, scores.ItemsAttempted, s.StudentID 
FROM
	[Core].[Student] [s]
	INNER JOIN [Core].[Document] [sd] ON [sd].[AdministrationID] = [s].[AdministrationID] AND [sd].[StudentID] = [s].[StudentID]
	LEFT JOIN [Core].[TestEvent] [te] ON [te].[AdministrationID] = [s].[AdministrationID] AND [te].[DocumentID] = [sd].[DocumentID]
	LEFT JOIN [Scoring].[Tests] [t] ON [t].[AdministrationID] = [s].[AdministrationID] AND [t].[Test] = [te].[Test]
	left join Scoring.TestLevels [tl] ON te.AdministrationID=tl.AdministrationID and tl.Test=te.Test and tl.Level=te.Level
	left join TestSession.Links [tsl] ON sd.AdministrationID=tsl.AdministrationID and sd.DocumentID=tsl.DocumentID
	left join Core.TestSession [ts] ON tsl.AdministrationID=ts.AdministrationID and tsl.TestSessionID=ts.TestSessionID
	cross apply (select nonmcitems=count(*) from Scoring.TestFormItems x inner join Scoring.Items i on i.AdministrationID=x.AdministrationID and i.Test=x.Test and i.ItemID=x.ItemID where x.AdministrationID=te.AdministrationID and x.Test=te.Test and x.Level=te.Level and x.Form=te.Form and i.ItemType!='MC') nonmcitems
	cross apply (select nonmcscored=count(distinct x.ItemID) from TestEvent.ItemScores x inner join Scoring.Items i on i.AdministrationID=x.AdministrationID and i.Test=x.Test and i.ItemID=x.ItemID where x.AdministrationID=te.AdministrationID and x.Test=te.Test and x.TestEventID=te.TestEventID and i.ItemType!='MC') nonmcscored
	left JOIN TestEvent.TestScores scores ON scores.AdministrationID=[s].AdministrationID  and scores.TestEventID = [te].TestEventID 
	left JOIN Scoring.TestScores scoreDef ON scoreDef.AdministrationID=scores.AdministrationID and scoreDef.Score=scores.Score and scoreDef.Test = te.Test          
WHERE
    [s].[AdministrationID] = @AdministrationID AND
    (ISNULL(@LastNameLike, '') = '' OR [s].[LastName] LIKE @LastNameLike + '%') AND
    (ISNULL(@FirstNameLike, '') = '' OR [s].[FirstName] LIKE @FirstNameLike + '%') AND
    (ISNULL(@districtCode, '') = '' OR [s].[DistrictCode] = @districtCode) AND
    (ISNULL(@schoolCode, '') = '' OR [s].[SchoolCode] = @schoolCode) AND
    (ISNULL(@Grade, '') = '' OR [s].[Grade] = @Grade) AND
    (ISNULL(@anyStudentIdLike, '') = '' OR
        [s].[StateStudentId] LIKE @anyStudentIdLike + '%' OR
        [s].[DistrictStudentId] LIKE @anyStudentIdLike + '%' OR
        [s].[SchoolStudentId] LIKE @anyStudentIdLike + '%' OR
        [s].[VendorStudentId] LIKE @anyStudentIdLike + '%') AND
       
    (ISNULL(@batchNumberLike, '') = '' OR [sd].[BatchNumber] LIKE @batchNumberLike + '%') AND
    (ISNULL(@lithoCodeLike, '') = '' OR [sd].[LithoCode] LIKE @lithoCodeLike + '%') AND
    (ISNULL(@serialNumberLike, '') = '' OR [sd].[SerialNumber] LIKE @serialNumberLike + '%') AND
    (ISNULL(@securityCodeLike, '') = '' OR [sd].[SecurityCode] LIKE @securityCodeLike + '%') AND
    (ISNULL(@ProcessingPriorityLike, '') = '' OR [sd].[Priority] LIKE @ProcessingPriorityLike + '%') AND
    (ISNULL(@testLike, '') = '' OR [tl].[Test] LIKE @testLike + '%' OR [tl].[Description] LIKE @testLike + '%')
	and (not te.AdministrationID is NULL and not t.AdministrationID is NULL)
	AND (
		   EXISTS (
			SELECT DISTINCT se.AdministrationID,StudentID 
			FROM Student.Extensions se, Config.Extensions   ce
				WHERE se.Category = 'General' AND se.Name = 'IsVisible' AND UPPER(se.Value) = 'Y'
		         AND se.AdministrationID = s.AdministrationID
				 AND se.StudentID = s.StudentID		
				 AND (ce.AdministrationID = s.AdministrationID or ce.AdministrationID = 0)
				 AND ce.Name = 'ConfigUI.EnableSearchStudentWithExtensionIsVisible' and UPPER(ce.value) = 'Y'			 	
		   ) OR 
		   NOT EXISTS (
			 SELECT 1 FROM Config.Extensions ce 
			 WHERE (ce.AdministrationID = s.AdministrationID or ce.AdministrationID = 0)
				 AND ce.Name = 'ConfigUI.EnableSearchStudentWithExtensionIsVisible' and UPPER(ce.value) = 'Y')
		)
    option(recompile)

IF ISNULL(@batchNumberLike, '') = '' AND
       ISNULL(@testLike, '') = '' AND
       ISNULL(@lithoCodeLike, '') = '' AND
       ISNULL(@serialNumberLike, '') = '' AND
       ISNULL(@securityCodeLike, '') = '' AND
       ISNULL(@ProcessingPriorityLike, '') = '' AND
       @onlyTestedStudents = 0
       begin
			  INSERT @Results
              SELECT distinct
                     s.AdministrationID ,
                     [s].[LastName], [s].[FirstName], [s].[MiddleName], [s].[DistrictCode],[s].[SchoolCode], [s].[Grade], [s].[DistrictStudentID],
                     [s].[VendorStudentID], [s].[SchoolStudentID],    [s].[BirthDate],  [s].[Gender], [s].[StateStudentID],
                     '' as AssessmentName, '' as FormName, '' as BatchNbr, '' as SerialNbr, '' as SecurityCode,
                     '' as Lithocode,   '' AS Mode,'' as Precode, '' AS ProcessingPriority,'' as ScoringStatus,
                     '' as ScoreName,'' AS RawScore,'' AS ScaleScore,'' AS PerformanceLevel,'' as AttemptedStatus, '' as ItemsAttempted, s.StudentID 
              FROM [Core].[Student] [s] 
              WHERE
                     [s].[AdministrationID] = @AdministrationID AND
                     (ISNULL(@LastNameLike, '') = '' OR [s].[LastName] LIKE @LastNameLike + '%') AND
                     (ISNULL(@FirstNameLike, '') = '' OR [s].[FirstName] LIKE @FirstNameLike + '%') AND
                     (ISNULL(@districtCode, '') = '' OR [s].[DistrictCode] = @districtCode) AND
                     (ISNULL(@schoolCode, '') = '' OR [s].[SchoolCode] = @schoolCode) AND
                     (ISNULL(@Grade, '') = '' OR [s].[Grade] = @Grade) AND
                     (ISNULL(@anyStudentIdLike, '') = '' OR
                     [s].[StateStudentId] LIKE @anyStudentIdLike + '%' OR
                     [s].[DistrictStudentId] LIKE @anyStudentIdLike + '%' OR
                     [s].[SchoolStudentId] LIKE @anyStudentIdLike + '%' OR
                     [s].[VendorStudentId] LIKE @anyStudentIdLike + '%')
					 and s.StudentID not in (select [StudentId] from @Results)
					 AND (
					   EXISTS (
						SELECT DISTINCT se.AdministrationID,StudentID 
						FROM Student.Extensions se, Config.Extensions   ce
							WHERE se.Category = 'General' AND se.Name = 'IsVisible' AND UPPER(se.Value) = 'Y'
							 AND se.AdministrationID = s.AdministrationID
							 AND se.StudentID = s.StudentID		
							 AND (ce.AdministrationID = s.AdministrationID or ce.AdministrationID = 0)
							 AND ce.Name = 'ConfigUI.EnableSearchStudentWithExtensionIsVisible' and UPPER(ce.value) = 'Y'			 	
					   ) OR 
					   NOT EXISTS (
						 SELECT 1 FROM Config.Extensions ce 
						 WHERE (ce.AdministrationID = s.AdministrationID or ce.AdministrationID = 0)
							 AND ce.Name = 'ConfigUI.EnableSearchStudentWithExtensionIsVisible' and UPPER(ce.value) = 'Y')
					)
       end
	     
SELECT AdministrationName,[LastName],[FirstName],[MiddleName],[DistrictCode],[SchoolCode],Grade,[DistrictStudentId],[VendorStudentId],
	[SchoolStudentId],[BirthDate],[Gender],[StateStudentId],AssessmentName,FormName,BatchNbr,SerialNbr,SecurityCode,Lithocode,
	Mode,Precode,ProcessingPriority,ScoringStatus,ScoreName,RawScore,ScaleScore,PerformanceLevel,AttemptedStatus,ItemsAttempted 
	FROM @Results
GO
