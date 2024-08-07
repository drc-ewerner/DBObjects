USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetEligibleGradesByStudent]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Joe Calderon	
-- Create date: 12/15/2011
-- Description:	Returns grade options, if any, when enforcing eligible grades
-- Changed to get grades for any student based on the grade for the sessions the sudent
-- belongs to, regardless of status. The commented out line query based on specific status in the session
-- =============================================
-- Author:		Chris Hedberg
-- Create date: 11/14/2014
-- Description:	This version of the procedure has been identified to be used 
--				for all clients. Any deviations will need to use a separate proc.
-- =============================================
-- Author:		Aaron Robertson
-- Create date: 1/13/2016
-- Description:	AdministrationID was added to join of Scoring.TestLevelGrades.  See JIRA ED-951
-- =============================================
-- Author:		Robert Lim
-- Create date: 7/22/2019
-- Description:	Added handling for PA CDT sub levels with format LEVEL-SUBLEVEL.  See JIRA ED-4987
-- =============================================
CREATE PROCEDURE [eWeb].[GetEligibleGradesByStudent]
	@administrationID INTEGER,
	@studentId INTEGER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select l.grade
	from Core.TestSession g
	inner join TestSession.Links k on k.AdministrationID=g.AdministrationID and k.TestSessionID=g.TestSessionID
	inner join Core.Student s on s.AdministrationID=g.AdministrationID and s.StudentID=k.StudentID
	inner join Scoring.TestLevelGrades l on (g.level = l.level or g.Level = iif(charindex('-',l.Level)>0, left(l.Level,charindex('-',l.Level)-1),l.level))
	      and l.Test=g.Test and l.AdministrationID = g.AdministrationID	
	where
		s.AdministrationID = @administrationID and 
		s.StudentID = @studentId
	Group By l.grade
END
GO
