USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetExistingAssessments]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [eWeb].[GetExistingAssessments]
	@AdministrationID int,
	@StudentId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT DISTINCT Core.Student.AdministrationID, Core.Student.StudentID, Scoring.TestLevels.Test, Scoring.TestLevels.Description,Scoring.TestLevels.Level, t.ContentArea
	FROM TestSession.Links INNER JOIN
         Core.TestSession ON TestSession.Links.AdministrationID = Core.TestSession.AdministrationID AND 
         TestSession.Links.TestSessionID = Core.TestSession.TestSessionID INNER JOIN
         Core.Student ON TestSession.Links.AdministrationID = Core.Student.AdministrationID AND 
         TestSession.Links.StudentID = Core.Student.StudentID INNER JOIN
         Scoring.TestLevels ON Core.TestSession.AdministrationID = Scoring.TestLevels.AdministrationID AND 
         Core.TestSession.Test = Scoring.TestLevels.Test AND Core.TestSession.[Level] = Scoring.TestLevels.[Level]
		 inner join Scoring.Tests t on Scoring.TestLevels.AdministrationID=t.AdministrationID and Scoring.TestLevels.Test=t.Test
		 inner join Scoring.ContentAreas ca on t.AdministrationID = ca.AdministrationID and t.ContentArea = ca.ContentArea
     WHERE 	Core.Student.AdministrationID =  @AdministrationID 
     AND	Core.Student.StudentID =  @StudentId      
	 order by t.ContentArea,Scoring.TestLevels.[Description],Scoring.TestLevels.Level
        

END
GO
