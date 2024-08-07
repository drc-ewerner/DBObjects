USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentsForDynamicReports]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [eWeb].[GetStudentsForDynamicReports]
(
	@AdminID INT, @DistrictCode VARCHAR(15), @SchoolCode VARCHAR(15), @Grade VARCHAR(2)
	, @SessionName VARCHAR(100), @LastName NVARCHAR(100), @FirstName NVARCHAR(100)
	, @StateStudentID VARCHAR(20)
) 
WITH RECOMPILE
AS
BEGIN

DECLARE @sess TABLE(AdminID INT, StudentID INT, TestSessionID INT PRIMARY KEY CLUSTERED(AdminID, StudentID, TestSessionID))

IF @SessionName IS NOT NULL AND @SessionName != ''
	INSERT INTO @sess
	SELECT DISTINCT ts.AdministrationID, tl.StudentID, ts.TestSessionID
	FROM Core.TestSession ts
	INNER JOIN TestSession.Links tl
		ON tl.AdministrationID = ts.AdministrationID AND tl.TestSessionID = ts.TestSessionID
	WHERE ts.AdministrationID = @AdminID AND ts.Name LIKE '%' + @SessionName + '%'

SELECT DISTINCT
	  cs.LastName
	, cs.FirstName
	, cs.StateStudentID
	, ISNULL(CONVERT(VARCHAR, cs.BirthDate, 101), '') AS BirthDate
	, cs.Grade
	, cs.StudentID
FROM Core.Student cs
LEFT OUTER JOIN @sess se
	ON se.AdminID = cs.AdministrationID AND se.StudentID = cs.StudentID
WHERE cs.AdministrationID = @AdminID
	AND (@DistrictCode IS NULL OR @DistrictCode = '' OR cs.DistrictCode = @DistrictCode)
	AND (@SchoolCode IS NULL OR @SchoolCode = '' OR cs.SchoolCode = @SchoolCode)
	AND (@Grade IS NULL OR @Grade = '' OR cs.Grade = @Grade)
	AND (@LastName IS NULL OR @LastName = '' OR cs.LastName LIKE '%' + @LastName + '%')
	AND (@FirstName IS NULL OR @FirstName = '' OR cs.FirstName LIKE '%' + @FirstName + '%')
	AND (@StateStudentID IS NULL OR @StateStudentID = '' OR cs.StateStudentID LIKE '%' + @StateStudentID + '%')
	AND (@SessionName IS NULL OR @SessionName = '' OR se.AdminID IS NOT NULL)

END
GO
