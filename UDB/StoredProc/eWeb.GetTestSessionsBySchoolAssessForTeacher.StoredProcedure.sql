USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestSessionsBySchoolAssessForTeacher]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetTestSessionsBySchoolAssessForTeacher]
	@AdministrationID   int,
	@TeacherID			int,
	@DistrictCode       varchar(15),
	@SchoolCode         varchar(15),
	@Test               varchar(50),
	@Level              varchar(20)

AS

;
WITH DC_Assessment AS (
  SELECT t.AdministrationID, tsl.Test, tsl.[Level], tsl.SubTest, tsl.SubLevel, tl.[Description]
	FROM Scoring.Tests t
		JOIN Scoring.TestLevels tl 
			ON tl.AdministrationID=t.AdministrationID 
				AND tl.Test=t.Test
		JOIN Scoring.TestSessionSubTestLevels tsl 
			ON tl.AdministrationID = tsl.AdministrationID 
				AND tl.Level = tsl.Level 
				AND tl.Test = tsl.Test
	WHERE t.AdministrationID = @AdministrationID 
		AND T.Test=@Test 
		AND TSL.SubLevel=@Level
)

SELECT 
	 MAX(s.Name)                          AS Name
	,s.TestSessionID                      AS TestSessionID
	,MAX(ISNULL(t.ContentArea,t.Test))    AS ContentArea
	,MAX(s.Test)                          AS Test
	,MAX(tl.Level)                        AS Level
	,MAX(ISNULL(dca.Description, 
		ISNULL(tl.Description,tl.Level))) AS AssessmentText
	,CASE
	   WHEN MAX(dca.Description) IS NULL 
		 THEN '' 
	   ELSE MAX(ISNULL(tl.Description, tl.Level)) 
	 END								  AS DiagnosticCategoryText
	,CASE 
	   WHEN MIN(x.Status) = 'Not Started'
	     THEN 'Not Started'
       WHEN MAX(x.Status) = 'Completed' 
	     THEN 'Completed' 
	   ELSE 'In Progress' 
	 END                                  AS Status
	,s.StartTime                          AS StartTime
	,s.EndTime                            AS EndTime
	,s.DistrictCode                       AS DistrictCode
	,s.SchoolCode                         AS SchoolCode
	,dist.SiteName                        AS DistrictName
	,sch.SiteName                         AS SchoolName
	,s.Mode                               AS Mode
	,s.ClassCode                          AS ClassCode
	,NULL                                 AS StudentCountInCurrentUserGroup
	,COUNT(*)                             AS TotalStudentCount
FROM       Core.TestSession          s
INNER JOIN Core.Site                 dist ON   s.AdministrationID  = dist.AdministrationID 
                                           AND s.DistrictCode      = dist.SiteCode 
										   AND dist.SuperSiteCode  = 'DEPTOFED'
INNER JOIN Core.Site                 sch  ON   s.AdministrationID  = sch.AdministrationID 
                                           AND s.DistrictCode      = sch.SuperSiteCode 
										   AND s.SchoolCode        = sch.SiteCode
INNER JOIN Scoring.Tests             t    ON   t.AdministrationID  = s.AdministrationID 
                                           AND t.Test              = s.Test
INNER JOIN Scoring.TestLevels        tl   ON   tl.AdministrationID = s.AdministrationID 
                                           AND tl.Test             = s.Test 
										   AND tl.Level            = s.Level
INNER JOIN TestSession.Links         k    ON   k.AdministrationID  = s.AdministrationID 
                                           AND k.TestSessionID     = s.TestSessionID
INNER JOIN Document.TestTicketView   x    ON   x.AdministrationID  = s.AdministrationID 
                                           AND x.DocumentID        = k.DocumentID
LEFT JOIN DC_Assessment				 dca  ON   s.Test			   = dca.SubTest
										   AND tl.Level            = dca.SubLevel
INNER JOIN StudentGroup.Links gk on gk.AdministrationID=s.AdministrationID and gk.StudentID=k.StudentID
INNER JOIN Teacher.StudentGroups tg on tg.AdministrationID=s.AdministrationID and tg.GroupID=gk.GroupID and tg.TeacherId=s.TeacherId 

WHERE s.AdministrationID = @AdministrationID 
  AND dist.SiteCode      = @DistrictCode 
  AND sch.SiteCode       = @SchoolCode
  AND s.Test             = @Test
  AND s.Level            = @Level
  AND s.TeacherID		 = @TeacherID
GROUP BY s.AdministrationID
        ,s.TestSessionID
		,s.StartTime
		,s.EndTime
		,s.DistrictCode
		,s.SchoolCode
		,dist.SiteName
		,sch.SiteName
		,s.Mode
		,s.ClassCode
GO
