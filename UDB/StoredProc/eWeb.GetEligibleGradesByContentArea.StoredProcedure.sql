USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetEligibleGradesByContentArea]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[GetEligibleGradesByContentArea]
	@adminID      int
   ,@contentArea  varchar(50)
	
AS
BEGIN
	SELECT DISTINCT xg.Grade 
	FROM Xref.Grades               xg
	JOIN Scoring.TestLevelGrades   tlg   ON   xg.AdministrationID  = tlg.AdministrationID
	                                      AND xg.Grade             = tlg.Grade
	JOIN Scoring.Tests             t     ON   tlg.AdministrationID = t.AdministrationID
	                                      AND tlg.Test             = t.Test
	WHERE tlg.AdministrationID = @adminID
	  AND t.ContentArea        = @contentArea
	ORDER BY xg.grade ASC
END
GO
