USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetHistoricalStudentID]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [eWeb].[GetHistoricalStudentID]
      @AdministrationID            int
     ,@StudentID                   int
     ,@HistoricalAdministrationID  int
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @StateStudentID varchar(20), @DistrictCode VARCHAR(15), @SchoolCode VARCHAR(15)
	SELECT @StateStudentID = StateStudentID, @DistrictCode = s.DistrictCode, @SchoolCode = s.SchoolCode
	FROM Core.Student s
	WHERE s.AdministrationID = @AdministrationID
	  AND s.StudentID        = @StudentID

	SELECT s.StudentID
	FROM Core.Student s
	WHERE s.AdministrationID = @HistoricalAdministrationID
	  AND s.StateStudentID   = @StateStudentID
	ORDER BY CASE /* make sure matching district/school is the first entry */
				WHEN @DistrictCode = s.DistrictCode AND @SchoolCode = s.SchoolCode THEN 0
				ELSE 1
			 END
END
GO
