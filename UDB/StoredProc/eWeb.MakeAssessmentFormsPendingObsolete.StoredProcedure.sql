USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[MakeAssessmentFormsPendingObsolete]    Script Date: 7/2/2024 9:21:54 AM ******/
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
