USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetDiagnosticCategoryAssessmentsByContentArea]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetDiagnosticCategoryAssessmentsByContentArea] 
(@AdministrationID int,@ContentArea varchar(50))

AS

SELECT distinct
	t.Test,tl.Level,
	AssessmentText=isnull(tl.Description,tl.Level)
FROM Scoring.Tests t
join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
join Scoring.TestSessionSubTestLevels tsl on tl.AdministrationID = tsl.AdministrationID and tl.Level = tsl.Level and tl.Test = tsl.Test
left join Config.Extensions ext on ext.AdministrationID=tl.AdministrationID and ext.Category='eWeb' and ext.Name=tl.Test + '.' + tl.Level + '.Hide'
WHERE t.AdministrationID=@AdministrationID and t.ContentArea=@ContentArea and tl.Description not like '$%'
and isnull(ext.Value, 'N') = 'N'
ORDER BY t.Test,tl.Level,AssessmentText
GO
