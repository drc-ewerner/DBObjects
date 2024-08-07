USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTicketsBySessionWithItemCounts_EJW]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetTicketsBySessionWithItemCounts_EJW] 
       @AdministrationID INT,
       @TestSessionID INT,
       @LastName VARCHAR (100) = null,
       @Status VARCHAR (100) = null
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	--IF OBJECT_ID('tempdb..@Results') IS NOT NULL DROP TABLE @Results;

	DECLARE @showAccommByAssignedForm bit

	DECLARE @Results TABLE
	--CREATE TABLE @Results
		(AdministrationID INT NOT NULL,
		 DocumentID INT NOT NULL,
		 Test VARCHAR(50) NULL,
		 [Level] VARCHAR(20) NULL,
		 Form VARCHAR(20) NULL,
		 UserName VARCHAR(50) NOT NULL,
		 [Password] VARCHAR(20) NOT NULL,
		 Spiraled INT NULL,
		 NotTestedCode VARCHAR(50) NULL,
		 [Status] VARCHAR(50) NOT NULL,
		 StudentID INT NOT NULL,
		 SchoolStudentID VARCHAR(30) NULL,
		 StateStudentID VARCHAR(30) NULL,
		 DistrictStudentID VARCHAR(30) NULL,
		 FirstName VARCHAR(100) NULL,
		 LastName VARCHAR(100) NULL,
		 MiddleName VARCHAR(100) NULL, 
		 BirthDate DATETIME NULL,
		 Grade VARCHAR(2) NULL,
		 FormName VARCHAR(50),
		 VisualIndicator VARCHAR(2) NULL,
		 StartTime DATETIME NULL,
		 EndTime DATETIME NULL,
		 LocalStartTime DATETIME NULL,
		 LocalEndTime DATETIME NULL,
		 LocalOffSet INT NULL,
		 UnlockTime DATETIME NULL,
		 TestSessionID INT NOT NULL,
		 Accommodations VARCHAR(400) NOT NULL DEFAULT '',
		 PartName VARCHAR(100) NOT NULL DEFAULT '',
		 NoAssessedCode INT NULL,
		 NonPublicEnrolled BIT NULL,
		 Answered INT NULL,
		 Total INT NULL,
		 AbbrevAccomodations VARCHAR(400) NULL,
		 DisplayValue VARCHAR(300) NULL,
		 ClassCode VARCHAR(15) NULL,
		 TeacherID INT NULL,
		 TeacherFirstName VARCHAR(100) NULL,
		 TeacherLastName VARCHAR(100) NULL,
		 FormSessionName VARCHAR(50) NULL,
		 TimeZone VARCHAR(5) NULL,
		 ContentArea VARCHAR(50) NULL);

	--CREATE INDEX ix_AdministrationIDTest ON @Results (AdministrationID, Test);
	--CREATE INDEX ix_AdministrationIDTestLevelForm ON @Results (AdministrationID, Test, [Level], Form);
	--CREATE INDEX ix_StatusTestLastFirst ON @Results ([Status], Test, LastName, FirstName);
	--CREATE INDEX ix_AdministrationIDDocumentID ON @Results (AdministrationID, DocumentID);
		 
	SET @showAccommByAssignedForm = 0;
	SELECT @showAccommByAssignedForm = CASE WHEN eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','TestTickets.ShowAccommByAssignedForm','N')='Y' THEN 1 ELSE 0 END;

	INSERT INTO @Results (AdministrationID, DocumentID, Test, [Level], Form, UserName, [Password], Spiraled, NotTestedCode, [Status], StudentId, SchoolStudentID,
	                      StateStudentID, DistrictStudentID, FirstName, LastName, MiddleName, BirthDate, Grade, StartTime, EndTime, LocalStartTime, LocalEndTime,
						  LocalOffSet, UnlockTime, TestSessionID, ClassCode, TimeZone, TeacherID,
						  FormName, VisualIndicator, FormSessionName, PartName)
		SELECT
			TestTicketView.AdministrationID,
			TestTicketView.DocumentID,
			TestTicketView.Test,
			TestTicketView.[Level],
			TestTicketView.Form,
			TestTicketView.UserName,
			TestTicketView.[Password],
			TestTicketView.Spiraled,
			TestTicketView.NotTestedCode,
			TestTicketView.[Status],
			Student.StudentID,
			Student.DistrictStudentID AS 'SchoolStudentID',
			Student.StateStudentID,
			Student.DistrictStudentID,
			Student.FirstName,
			Student.LastName,
			Student.MiddleName,
			Student.BirthDate,
			Student.Grade,
			TestTicketView.StartTime,
			TestTicketView.EndTime,
			TestTicketView.LocalStartTime, 
			TestTicketView.LocalEndTime, 
			DATEDIFF(hh,TestTicketView.StartTime,TestTicketView.LocalStartTime) AS 'LocalOffset',
			TestTicketView.UnlockTime,
			TestSession.TestSessionID,
			TestSession.ClassCode,
			TestTicketView.TimeZone,
			TestSession.TeacherID,
			FormName = TestForms.FormName,
			VisualIndicator = TestForms.VisualIndicator,
			FormSessionName = TestForms.FormSessionName,
			PartName = CASE WHEN TestTicketView.PartName IS NULL 
								THEN '' 
							WHEN ISNULL(TestForms.FormSessionName,'') = '' 
								THEN 'Module ' + TestTicketView.PartName 
							ELSE TestForms.FormSessionName 
						END
		FROM
			Core.TestSession TestSession
				JOIN 
			TestSession.Links Links 
				ON Links.AdministrationID = TestSession.AdministrationID AND
				   Links.TestSessionID = TestSession.TestSessionID
				JOIN 
			Document.TestTicketView TestTicketView 
				ON TestTicketView.AdministrationID = Links.AdministrationID AND
				   TestTicketView.DocumentID = Links.DocumentID
				JOIN 
			Core.Student Student 
				ON Student.AdministrationID = TestSession.AdministrationID AND
				   Student.StudentID = Links.StudentID
				JOIN
			Scoring.TestForms AS TestForms
				ON TestTicketView.AdministrationID = TestForms.AdministrationID AND
				   TestTicketView.Test = TestForms.Test AND
				   TestTicketView.[Level] = TestForms.[Level] AND
				   TestTicketView.Form = TestForms.Form
		WHERE
			TestSession.AdministrationID = @AdministrationID AND
			TestSession.TestSessionID = @TestSessionID  AND
			(ISNULL(@LastName, '') = '' OR Student.LastName LIKE @LastName + '%') AND
			COALESCE(TestTicketView.[Status],'')= CASE WHEN  @Status <> '(All)' THEN COALESCE(@status,TestTicketView.[Status],'') ELSE TestTicketView.[status] END

	-- Get content area as that will be utilized in later joins
	UPDATE
		@Results
	SET
		ContentArea = ScoringTests.ContentArea
	FROM
		@Results AS Results
			JOIN
		Scoring.Tests AS ScoringTests
			ON Results.AdministrationID = ScoringTests.AdministrationID AND
			   Results.Test = ScoringTests.Test;

	-- Get the student accomodations.
	UPDATE
		@Results
	SET
		Accommodations = COALESCE(LEFT(StudentAccommodations, LEN(StudentAccommodations) - 1), '')
	FROM
		@Results AS Results
			OUTER APPLY 
		(SELECT
			StudentExtensionNames.DisplayName + ', '
		FROM
			xref.studentextensionnames AS StudentExtensionNames
				JOIN 
			Student.Extensions AS StudentExtensions 
				ON StudentExtensionNames.Category = StudentExtensions.Category AND
					StudentExtensionNames.[Name] = StudentExtensions.[Name] AND
					StudentExtensionNames.AdministrationID = StudentExtensions.AdministrationID
				JOIN 
			Config.Extensions AS ConfigExtensions 
				ON ConfigExtensions.Category = 'Accommodation.Online' AND
					ConfigExtensions.AdministrationID = StudentExtensions.AdministrationID AND
					ConfigExtensions.[Name] = StudentExtensions.Category + '.' + StudentExtensions.[Name]
		WHERE
				StudentExtensions.[AdministrationID] = Results.[AdministrationID] AND
				StudentExtensions.[StudentID] = Results.[StudentID] AND
				StudentExtensions.[Category] = Results.[ContentArea] AND
				StudentExtensions.[Value] = 'Y' AND
				((@showAccommByAssignedForm = 1 AND 
					NOT EXISTS(SELECT 
								1 
							FROM 
								Scoring.TestAccommodationForms a 
							WHERE 
								a.AdministrationID = StudentExtensionNames.AdministrationID AND 
								a.Test = Results.Test AND 
								a.[Level]=Results.[Level] AND
								a.AccommodationName = StudentExtensionNames.[Name] AND
								LEFT(a.Form,6) != LEFT(Results.Form,6))) OR 
					@showAccommByAssignedForm = 0)
		GROUP BY 
			StudentExtensionNames.DisplayName
		ORDER BY 
			StudentExtensionNames.DisplayName
		FOR XML PATH('')) StudentExtensionNames (StudentAccommodations);

	-- Get the student abbreviation accomodations.
	UPDATE
		@Results
	SET
		AbbrevAccomodations = COALESCE(LEFT(StudentAccommodations, LEN(StudentAccommodations) - 1), '')
	FROM
		@Results AS Results
			OUTER APPLY 
		(SELECT
			StudentExtensionNames.DisplayAbbreviation + ', '
		FROM
			xref.studentextensionnames AS StudentExtensionNames
				JOIN 
			Student.Extensions AS StudentExtensions 
				ON StudentExtensionNames.Category = StudentExtensions.Category AND
					StudentExtensionNames.[Name] = StudentExtensions.[Name] AND
					StudentExtensionNames.AdministrationID = StudentExtensions.AdministrationID
				JOIN 
			Config.Extensions AS ConfigExtensions 
				ON ConfigExtensions.Category = 'Accommodation.Online' AND
					ConfigExtensions.AdministrationID = StudentExtensions.AdministrationID AND
					ConfigExtensions.[Name] = StudentExtensions.Category + '.' + StudentExtensions.[Name]
		WHERE
				StudentExtensions.[AdministrationID] = Results.[AdministrationID] AND
				StudentExtensions.[StudentID] = Results.[StudentID] AND
				StudentExtensions.[Category] = Results.[ContentArea] AND
				StudentExtensions.[Value] = 'Y' AND
				((@showAccommByAssignedForm = 1 AND 
					NOT EXISTS(SELECT 
								1 
							FROM 
								Scoring.TestAccommodationForms a 
							WHERE 
								a.AdministrationID = StudentExtensionNames.AdministrationID AND 
								a.Test = Results.Test AND 
								a.[Level]=Results.[Level] AND
								a.AccommodationName = StudentExtensionNames.[Name] AND
								LEFT(a.Form,6) != LEFT(Results.Form,6))) OR 
					@showAccommByAssignedForm = 0)
		GROUP BY 
			StudentExtensionNames.DisplayAbbreviation
		ORDER BY 
			StudentExtensionNames.DisplayAbbreviation
		FOR XML PATH('')) StudentExtensionNames (StudentAccommodations);

	-- Get the student answered value
	UPDATE
		@Results
	SET
		Answered = OnlineTestResponseCount.Answered
	FROM
		@Results AS Results
			OUTER APPLY 
       (SELECT
			COUNT(DISTINCT
				CASE
					WHEN (ExtendedResponse IS NULL) AND (ISNULL(Response, '') NOT IN ('', '-')) THEN OnlineTestResponses.ItemID
					WHEN (Response IS NULL) AND (ExtendedResponse LIKE '%answered="y"%') THEN OnlineTestResponses.ItemID
					ELSE NULL
				END) AS 'Answered'
       FROM
			Insight.OnlineTests AS OnlineTests
				LEFT JOIN 
			Insight.OnlineTestResponses OnlineTestResponses 
				ON OnlineTests.AdministrationID = OnlineTestResponses.AdministrationID AND
				   OnlineTests.OnlineTestID = OnlineTestResponses.OnlineTestID
       WHERE
            OnlineTests.AdministrationID = Results.AdministrationID AND
            OnlineTests.[DocumentID] = Results.DocumentID) OnlineTestResponseCount

	-- Get the student answered value
	UPDATE
		@Results
	SET
		Total = OnlineTestTotal.Total
	FROM
		@Results AS Results
			OUTER APPLY 
		(SELECT
			COUNT(DISTINCT TestFormItems.[ItemID]) AS 'Total'
		FROM
			Document.TestTicket TestTicket
				JOIN 
			Scoring.TestFormItems TestFormItems
				ON TestFormItems.AdministrationID = TestTicket.AdministrationID AND
				   TestFormItems.Test = TestTicket.Test AND
				   TestFormItems.[Level] = TestTicket.[Level] AND
				   TestFormItems.Form = Results.Form
		WHERE
			TestTicket.AdministrationID = Results.AdministrationID AND
			TestTicket.DocumentID = Results.DocumentID) OnlineTestTotal

	-- Get Document Non Assessed code and Non Public Enrolled
	UPDATE
		@Results
	SET
		NoAssessedCode = CAST(DocumentExtensionsCD.[Value] AS INT),
		NonPublicEnrolled = ISNULL(DocumentExtensionsEnrolled.[Value], CAST(DocumentExtensionsEnrolled.[Value] AS BIT))
	FROM
		@Results AS Results
			LEFT JOIN
		Document.Extensions AS DocumentExtensionsCD
			ON Results.AdministrationID = DocumentExtensionsCD.AdministrationID AND
			   Results.DocumentID = DocumentExtensionsCD.DocumentID AND
			   DocumentExtensionsCD.[Name] = 'NonAssessedCd'
			LEFT JOIN
		Document.Extensions AS DocumentExtensionsEnrolled
			ON Results.AdministrationID = DocumentExtensionsEnrolled.AdministrationID AND
			   Results.DocumentID = DocumentExtensionsEnrolled.DocumentID AND
			   DocumentExtensionsEnrolled.[Name] = 'NonPublicEnrolled';

	-- Get Student Extension value test type
	UPDATE
		@Results
	SET
		DisplayValue = StudentExtensionValues.DisplayValue
	FROM
		@Results AS Results
			LEFT JOIN
		Student.Extensions AS StudentExtensions
			ON Results.AdministrationID = StudentExtensions.AdministrationID AND
			   Results.StudentID = StudentExtensions.StudentID AND
			   StudentExtensions.[Name] = 'Test_Type' AND
			   StudentExtensions.Category = 'Demographic'
			LEFT JOIN
		XRef.StudentExtensionValues AS StudentExtensionValues
			ON Results.AdministrationID = StudentExtensionValues.AdministrationID AND
			   StudentExtensions.[Value] = StudentExtensionValues.[Value] AND
			   StudentExtensionValues.[Name] = 'Test_Type' AND
			   StudentExtensionValues.Category = 'Demographic'

	-- Get teacher data
	UPDATE
		@Results
	SET
		TeacherID = CoreTeacher.TeacherID,
		TeacherFirstName = CoreTeacher.FirstName,
		TeacherLastName = CoreTeacher.LastName
	FROM
		@Results AS Results
			LEFT JOIN
		Core.Teacher AS CoreTeacher
			ON Results.AdministrationID = CoreTeacher.AdministrationID AND
			   Results.TeacherID = CoreTeacher.TeacherID;

	SELECT 
		AdministrationID, 
		DocumentID, 
		Test, 
		[Level], 
		Form, 
		UserName, 
		[Password], 
		Spiraled, 
		NotTestedCode, 
		[Status], 
		StudentId, 
		SchoolStudentID,
		StateStudentID, 
		DistrictStudentID,
		FirstName, 
		LastName, 
		MiddleName, 
		BirthDate, 
		Grade,
		FormName,
		VisualIndicator,
		StartTime, 
		EndTime, 
		LocalStartTime, 
		LocalEndTime,
		LocalOffSet, 
		UnlockTime, 
		TestSessionID, 
		Accommodations,
		PartName,
		NoAssessedCode,
		NonPublicEnrolled,
		Answered,
		Total,
		AbbrevAccomodations,
		DisplayValue,
		ClassCode, 
		TeacherID,
		TeacherFirstName,
		TeacherLastName,
		FormSessionName,
		TimeZone
	FROM
		@Results 
	ORDER BY 
		[Status], 
		Test, 
		LastName, 
		FirstName;

--	DROP TABLE @Results;

END;

GO
