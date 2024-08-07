USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetDiagnosticCategoriesByAssessment]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetDiagnosticCategoriesByAssessment] 
(@AdministrationID INT, @Test VARCHAR(50), @Level VARCHAR(20))

AS

SELECT DISTINCT
	tl.Test,tl.Level,
	DiagnosticCategoryText=isnull(tl.Description,tl.Level)
FROM Scoring.TestSessionSubTestLevels tsl 
join Scoring.TestLevels tl on tsl.AdministrationID=tl.AdministrationID and tsl.SubTest=tl.Test and tsl.SubLevel=tl.Level
left join Config.Extensions ext on ext.AdministrationID=tl.AdministrationID and ext.Category='eWeb' and ext.Name=tl.Test + '.' + tl.Level + '.Hide'
WHERE tsl.AdministrationID=@AdministrationID and tsl.Test=@Test and tsl.Level=@Level and tl.Description not like '$%'
and isnull(ext.Value, 'N') = 'N'
ORDER BY tl.Test,tl.Level, DiagnosticCategoryText
GO
