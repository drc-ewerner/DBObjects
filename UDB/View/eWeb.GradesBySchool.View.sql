USE [Alaska_udb_dev]
GO
/****** Object:  View [eWeb].[GradesBySchool]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create VIEW [eWeb].[GradesBySchool]
AS
SELECT     CASE WHEN grade = '--' OR
                      grade = '**' OR
                      grade IS NULL THEN 'Unknown' ELSE grade END AS grade, 
		AdministrationID,DistrictCode,SchoolCode
FROM         Core.Student
GROUP BY AdministrationID, DistrictCode, SchoolCode, CASE WHEN grade = '--' OR
                      grade = '**' OR
                      grade IS NULL THEN 'Unknown' ELSE grade END
GO
