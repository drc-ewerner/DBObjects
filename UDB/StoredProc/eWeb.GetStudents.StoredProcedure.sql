USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudents]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [eWeb].[GetStudents](@AdminID AS INT
							, @StateStudentID VARCHAR(30) = NULL, @DistrictStudentID VARCHAR(30) = NULL
							, @DistrictCode VARCHAR(15) = NULL, @SchoolCode VARCHAR(15) = NULL
							, @LastName NVARCHAR(100) = NULL, @FirstName NVARCHAR(100) = NULL, @Gender VARCHAR(1) = NULL
							, @BirthDate DATETIME = NULL)
WITH RECOMPILE
AS
BEGIN
	SELECT 
	   [AdministrationID]
      ,[StudentID]
      ,[LastName]
      ,[FirstName]
      ,[MiddleName]
      ,[NameSuffix]
      ,[BirthDate]
      ,CAST([Gender] AS CHAR(1)) AS [Gender]
      ,[Grade]
      ,[StateStudentID]
      ,[DistrictStudentID]
      ,[SchoolStudentID]
      ,[DistrictCode]
      ,[SchoolCode]
      ,[VendorStudentID]
      ,[CreateDate]
      ,[UpdateDate]
	FROM Core.Student cs
	WHERE cs.AdministrationID = @AdminID
		AND (cs.StateStudentID = @StateStudentID OR @StateStudentID IS NULL)
		AND (cs.DistrictStudentID = @DistrictStudentID OR @DistrictStudentID IS NULL)
		AND (cs.DistrictCode = @DistrictCode OR @DistrictCode IS NULL)
		AND (cs.SchoolCode = @SchoolCode OR @SchoolCode IS NULL)
		AND (cs.LastName = @LastName OR @LastName IS NULL)
		AND (cs.FirstName = @FirstName OR @FirstName IS NULL)
		AND (cs.Gender = @Gender OR @Gender IS NULL)
		AND (cs.BirthDate = @BirthDate OR @BirthDate IS NULL)

END
GO
