USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[MakeAssessmentFormsPendingObsolete]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create PROCEDURE [eWeb].[MakeAssessmentFormsPendingObsolete]
@AdministrationID INT,
@Test varchar(50),
@Level varchar(20)
AS
Begin

UPDATE Scoring.TestForms
   SET [Status] = 'Obsolete-Pending'
 WHERE AdministrationID=@AdministrationID  And Test=@Test and Level=@Level
	And coalesce([status],'Active') = 'Active'

End
GO
