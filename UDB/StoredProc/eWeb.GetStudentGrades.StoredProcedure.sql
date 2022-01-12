USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentGrades]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [eWeb].[GetStudentGrades]
      @AdministrationID int, @StudentIDs XML
AS
BEGIN
	DECLARE @students TABLE
	(
		AdminID INT, StudentID INT, Grade VARCHAR(2)
		PRIMARY KEY CLUSTERED(AdminID, StudentID)
	)

	INSERT INTO @students(AdminID, StudentID)
	SELECT @AdministrationID, Tbl.Col.value('.', 'INT')
	FROM @StudentIDs.nodes('//ArrayOfInt/int') Tbl(Col)

	UPDATE s
	SET Grade = cs.Grade
	FROM @students s
	INNER JOIN Core.Student cs
		ON cs.AdministrationID = s.AdminID AND cs.StudentID = s.StudentID

	SELECT AdminID, StudentID, Grade FROM @students

END
GO
