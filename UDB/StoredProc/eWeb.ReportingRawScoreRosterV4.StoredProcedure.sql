USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportingRawScoreRosterV4]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[ReportingRawScoreRosterV4]
    @AdministrationID   int
   ,@DistrictCode       varchar(15)
   ,@SchoolCode         varchar(15)
   ,@Grade              varchar(2)
   ,@ContentArea        varchar(50)
AS

BEGIN

/* This proc is intended for use by NV only */

declare @_AdministrationID int,
		@_DistrictCode varchar(15),
		@_SchoolCode varchar(15),
		@_Grade varchar(2),
		@_ContentArea varchar(50)

set @_AdministrationID=@AdministrationID;
set @_DistrictCode=@DistrictCode;
set @_SchoolCode=@SchoolCode;
set @_Grade=@Grade
set @_ContentArea=@ContentArea

DECLARE @ScoreConfigAll varchar(1000) = 'ALL'
DECLARE @ScoreConfigC1  varchar(1000) = 'C1'
DECLARE @ScoreConfigC2  varchar(1000) = 'C2'
DECLARE @ScoreConfigC3  varchar(1000) = 'C3'
DECLARE @ScoreConfigC4  varchar(1000) = 'C4'
DECLARE @Test           varchar(50)   = (SELECT Test FROM Scoring.Tests WHERE AdministrationID = @_AdministrationID AND ContentArea = @_ContentArea);

SELECT DISTINCT
	AdministrationID
   ,DistrictName
   ,DistrictCode
   ,SchoolName
   ,SchoolCode
   ,ContentArea
   ,Grade
   ,LastName
   ,FirstName
   ,StateStudentID
   ,Birthdate
   ,CAST(RawScore AS int)                         AS RawScoreAll
   ,CAST(MaxRawScore AS int)                      AS MaxRawScoreAll
   ,CAST(CASE WHEN TestStatus = 'AllScoringComplete' THEN ScaleScore ELSE -1 END AS int)                       AS ScaleScoreAll
   ,ISNULL(CASE WHEN TestStatus = 'AllScoringComplete' THEN PerformanceLevel END, 'N/A')               AS PerformanceLevelAll
   ,ISNULL(C1, 'N/A')                             AS Custom1
   ,ISNULL(C2, 'N/A')                             AS Custom2
   ,ISNULL(C3, 'N/A')                             AS Custom3
   ,ISNULL(C4, 'N/A')                             AS Custom4
   ,cts.Name                                      AS TestSessionName
FROM        (SELECT AdministrationID, TestSessionID, Name, Test, Level, DistrictCode, SchoolCode FROM Core.TestSession) cts
CROSS APPLY (SELECT StudentID, DocumentID FROM TestSession.Links WHERE AdministrationID = cts.AdministrationID AND TestSessionID = cts.TestSessionID) tsl
CROSS APPLY (SELECT LastName, FirstName, CAST(BirthDate AS date) AS Birthdate, Gender, Grade, StateStudentID FROM Core.Student WHERE AdministrationID = cts.AdministrationID AND StudentID = tsl.StudentID) cs
CROSS APPLY (SELECT ContentArea FROM Scoring.Tests WHERE AdministrationID = cts.AdministrationID AND Test = cts.Test) st
CROSS APPLY (SELECT Form, UserName, Password, BaseDocumentID FROM Document.TestTicket WHERE AdministrationID = cts.AdministrationID AND DocumentID = tsl.DocumentID AND Test = cts.Test AND Level = cts.Level) dtt
--CROSS APPLY (SELECT DISTINCT TestEventID, Form FROM Core.TestEvent WHERE AdministrationID = cts.AdministrationID AND DocumentID = ISNULL(dtt.BaseDocumentID, tsl.DocumentID) AND Test = cts.Test AND Level = cts.Level) cte
CROSS APPLY (SELECT DISTINCT TestEventID, Form FROM Core.TestEvent WHERE AdministrationID = cts.AdministrationID AND DocumentID = ISNULL(dtt.BaseDocumentID, tsl.DocumentID) AND Test = cts.Test) cte
CROSS APPLY (SELECT RawScore, ISNULL(ScaleScore, -1) AS ScaleScore, PerformanceLevel FROM TestEvent.TestScores WHERE AdministrationID = cts.AdministrationID AND TestEventID = cte.TestEventID AND Test = cts.Test AND Score = @ScoreConfigAll) tetsAll
CROSS APPLY (SELECT CAST(Value AS numeric) AS MaxRawScore, Name FROM TestEvent.Extensions WHERE AdministrationID = cts.AdministrationID AND Test = cts.Test AND Name = 'MaxRawAttempted' + @ScoreConfigAll AND TestEventID = cte.TestEventID) teeAll
OUTER APPLY (SELECT PerformanceLevel AS C1 FROM TestEvent.TestScores WHERE AdministrationID = cts.AdministrationID AND TestEventID = cte.TestEventID AND Test = cts.Test AND Score = @ScoreConfigC1) tetsC1
OUTER APPLY (SELECT PerformanceLevel AS C2 FROM TestEvent.TestScores WHERE AdministrationID = cts.AdministrationID AND TestEventID = cte.TestEventID AND Test = cts.Test AND Score = @ScoreConfigC2) tetsC2
OUTER APPLY (SELECT PerformanceLevel AS C3 FROM TestEvent.TestScores WHERE AdministrationID = cts.AdministrationID AND TestEventID = cte.TestEventID AND Test = cts.Test AND Score = @ScoreConfigC3) tetsC3
OUTER APPLY (SELECT PerformanceLevel AS C4 FROM TestEvent.TestScores WHERE AdministrationID = cts.AdministrationID AND TestEventID = cte.TestEventID AND Test = cts.Test AND Score = @ScoreConfigC4) tetsC4
CROSS APPLY (SELECT SiteName AS DistrictName FROM Core.Site WHERE LevelID = 1 AND AdministrationID = cts.AdministrationID AND SiteCode = cts.DistrictCode) csdi
CROSS APPLY (SELECT SiteName AS SchoolName FROM Core.Site WHERE LevelID = 2 AND AdministrationID = cts.AdministrationID AND SiteCode = cts.SchoolCode AND SuperSiteCode = cts.DistrictCode) cssc
CROSS APPLY (SELECT TestStatus FROM TestEvent.TestStatus WHERE AdministrationID = cts.AdministrationID AND TestEventID = cte.TestEventID AND Test = cts.Test AND ((TestStatus = 'AutoScoringComplete') OR (TestStatus = 'AllScoringComplete'))) tetstat
WHERE AdministrationID = @_AdministrationID
  AND DistrictCode     = @_DistrictCode 
  AND SchoolCode       = @_SchoolCode 
  AND Test             = @Test 
  AND Level            IN (SELECT Level FROM Scoring.TestLevelGrades WHERE AdministrationID = @_AdministrationID AND Test = @Test AND Grade = @_Grade) 
  AND Grade            = @_Grade;

END

GO
