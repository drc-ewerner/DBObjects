USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[FindStudent]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[FindStudent] 
	@AdministrationID INT, 
	@maxResults INT, 
	@onlyTestedStudents BIT, 
	@DistrictCode varchar(15) = NULL, 
	@SchoolCode varchar(15) = NULL, 
	@Grade VARCHAR(2) = NULL, 
	@LastNameLike VARCHAR(100) = NULL,
	@FirstNameLike VARCHAR(100) = NULL,
	@AnyStudentIdLike VARCHAR(50) = NULL, 
	@batchNumberLike VARCHAR(30) = NULL,
	@lithoCodeLike VARCHAR(15) = NULL,
	@TestLike VARCHAR(50) = NULL,
	@serialNumberLike VARCHAR(6) = NULL, 
	@securityCodeLike VARCHAR(15) = NULL,
	@ProcessingPriorityLike VARCHAR(10) = NULL

AS

DECLARE @Results TABLE
(
	[AdministrationID] INT,
	[StudentId] INT,
	[DistrictCode] varchar(15),
	[SchoolCode] varchar(15),
	[LastName] VARCHAR(100) NULL,
	[FirstName] VARCHAR(100) NULL, 
	[MiddleName] VARCHAR(100) NULL, 
	[BirthDate] DATETIME NULL, 
	[Gender] VARCHAR(2) NULL, 
	[StateStudentId] VARCHAR(30) NULL,
	[DistrictStudentId] VARCHAR(30) NULL,
	[SchoolStudentId] VARCHAR(30) NULL,
	[VendorStudentId] VARCHAR(50) NULL
)

IF ISNULL(@batchNumberLike, '') = '' AND
	ISNULL(@testLike, '') = '' AND
	ISNULL(@lithoCodeLike, '') = '' AND
	ISNULL(@serialNumberLike, '') = '' AND
	ISNULL(@securityCodeLike, '') = '' AND
	ISNULL(@ProcessingPriorityLike, '') = '' AND
	@onlyTestedStudents = 0
BEGIN
	--this student may not have assessments, search should be easier
	INSERT @Results
	SELECT DISTINCT TOP (@maxResults)
		[s].[AdministrationID],
		[s].[StudentID],
		[s].[DistrictCode],
		[s].[SchoolCode],
		[s].[LastName],
		[s].[FirstName],
		[s].[MiddleName],
		[s].[BirthDate], 
		[s].[Gender], 
		[s].[StateStudentID],	
		[s].[DistrictStudentID],
		[s].[SchoolStudentID],
		[s].[VendorStudentID]
	FROM
		[Core].[Student] [s]
	WHERE
		[s].[AdministrationID] = @AdministrationID AND
		(ISNULL(@LastNameLike, '') = '' OR [s].[LastName] LIKE @LastNameLike) AND
		(ISNULL(@FirstNameLike, '') = '' OR [s].[FirstName] LIKE @FirstNameLike) AND
		(ISNULL(@districtCode, '') = '' OR [s].[DistrictCode] = @districtCode) AND
		(ISNULL(@schoolCode, '') = '' OR [s].[SchoolCode] = @schoolCode) AND
		(ISNULL(@Grade, '') = '' OR [s].[Grade] = @Grade) AND
		(ISNULL(@anyStudentIdLike, '') = '' OR
			[s].[StateStudentId] LIKE @anyStudentIdLike OR
			[s].[DistrictStudentId] LIKE @anyStudentIdLike OR
			[s].[SchoolStudentId] LIKE @anyStudentIdLike OR
			[s].[VendorStudentId] LIKE @anyStudentIdLike)
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
END
ELSE
BEGIN
	--this student has assessments, need to query extra tables
	INSERT @Results
	SELECT DISTINCT TOP (@maxResults)
		[s].[AdministrationID],
		[s].[StudentID],
		[s].[DistrictCode],
		[s].[SchoolCode],
		[s].[LastName],
		[s].[FirstName],
		[s].[MiddleName],
		[s].[BirthDate], 
		[s].[Gender], 
		[s].[StateStudentID],	
		[s].[DistrictStudentID],
		[s].[SchoolStudentID],
		[s].[VendorStudentID]
	FROM
		[Core].[Student] [s]
		INNER JOIN [Core].[Document] [sd] ON
			[sd].[AdministrationID] = [s].[AdministrationID] AND
			[sd].[StudentID] = [s].[StudentID]
		LEFT JOIN [Core].[TestEvent] [te] ON
			[te].[AdministrationID] = [s].[AdministrationID] AND
			[te].[DocumentID] = [sd].[DocumentID]
		LEFT JOIN [Scoring].[Tests] [t] ON
			[t].[AdministrationID] = [s].[AdministrationID] AND
			[t].[Test] = [te].[Test]
	WHERE
		[s].[AdministrationID] = @AdministrationID AND
		(ISNULL(@LastNameLike, '') = '' OR [s].[LastName] LIKE @LastNameLike) AND
		(ISNULL(@FirstNameLike, '') = '' OR [s].[FirstName] LIKE @FirstNameLike) AND
		(ISNULL(@districtCode, '') = '' OR [s].[DistrictCode] = @districtCode) AND
		(ISNULL(@schoolCode, '') = '' OR [s].[SchoolCode] = @schoolCode) AND
		(ISNULL(@Grade, '') = '' OR [s].[Grade] = @Grade) AND
		(ISNULL(@anyStudentIdLike, '') = '' OR
			[s].[StateStudentId] LIKE @anyStudentIdLike OR
			[s].[DistrictStudentId] LIKE @anyStudentIdLike OR
			[s].[SchoolStudentId] LIKE @anyStudentIdLike OR
			[s].[VendorStudentId] LIKE @anyStudentIdLike) AND
	
		(ISNULL(@batchNumberLike, '') = '' OR [sd].[BatchNumber] LIKE @batchNumberLike) AND
		(ISNULL(@lithoCodeLike, '') = '' OR [sd].[LithoCode] LIKE @lithoCodeLike) AND
		(ISNULL(@serialNumberLike, '') = '' OR [sd].[SerialNumber] LIKE @serialNumberLike) AND
		(ISNULL(@securityCodeLike, '') = '' OR [sd].[SecurityCode] LIKE @securityCodeLike) AND
		(ISNULL(@ProcessingPriorityLike, '') = '' OR [sd].[Priority] LIKE @ProcessingPriorityLike) AND

		(ISNULL(@testLike, '') = '' OR [t].[Test] LIKE @testLike OR [t].[Description] LIKE @testLike)
		and (not te.AdministrationID is NULL and not t.AdministrationID is NULL or @onlyTestedStudents = 0)
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
END

SELECT * FROM @Results
GO
