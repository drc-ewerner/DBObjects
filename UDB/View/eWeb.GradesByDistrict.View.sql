USE [Alaska_udb_dev]
GO
/****** Object:  View [eWeb].[GradesByDistrict]    Script Date: 11/21/2023 8:54:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create VIEW [eWeb].[GradesByDistrict]
AS
SELECT     CASE WHEN grade = '--' OR
                      grade = '**' OR
                      grade IS NULL THEN 'Unknown' ELSE grade END AS grade, AdministrationID,DistrictCode
FROM         Core.Student
GROUP BY AdministrationID, DistrictCode, CASE WHEN grade = '--' OR
                      grade = '**' OR
                      grade IS NULL THEN 'Unknown' ELSE grade END
GO
