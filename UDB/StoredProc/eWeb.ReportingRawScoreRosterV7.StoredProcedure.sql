USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportingRawScoreRosterV7]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[ReportingRawScoreRosterV7]
    @AdministrationID   int
   ,@DistrictCode       varchar(15)
   ,@SchoolCode         varchar(15)
   ,@Grade              varchar(2)
   ,@ContentArea        varchar(50)
   ,@AssessmentName     varchar(100)
AS

BEGIN

/* This proc is intended for use by MO only */

declare @_AdministrationID int,
		@_DistrictCode varchar(15),
		@_SchoolCode varchar(15),
		@_Grade varchar(2),
		@_ContentArea varchar(50),
		@_AssessmentName varchar(100)

set @_AdministrationID=@AdministrationID;
set @_DistrictCode=@DistrictCode;
set @_SchoolCode=@SchoolCode;
set @_Grade=@Grade
set @_ContentArea=@ContentArea
set @_AssessmentName=@AssessmentName

DECLARE @ScoreConfigAll varchar(1000) = 'ALL'
DECLARE @Test TABLE(Test Varchar(50) PRIMARY KEY CLUSTERED(Test))
DECLARE @EnforceLocalTimeZone varchar(10)=eWeb.GetConfigExtensionValue(@_AdministrationID,'eWeb','TimeZone.EnforceLocalTimeZone','N');
DECLARE @ScoreConfig varchar(1000)=eWeb.GetConfigExtensionValue(@_AdministrationID,'eWeb','Reporting.OnlineResults.ScoreSet','N');
DECLARE @Level TABLE(Level Varchar(20) PRIMARY KEY CLUSTERED(Level))

INSERT INTO @Test select distinct Test from Scoring.Tests where AdministrationID=@_AdministrationID and ContentArea=@_ContentArea
INSERT INTO @Level select distinct Level from Scoring.TestLevelGrades where AdministrationID=@_AdministrationID and Test in (select Test from @Test) and Grade=@_Grade
                                  


SELECT DISTINCT
	AdministrationID
   ,DistrictName
   ,DistrictCode
   ,SchoolName
   ,SchoolCode
   ,ContentArea
   ,AssessmentName=ISNULL(stl.[Description],stl.Level)
   ,Grade
   ,LastName
   ,FirstName
   ,StateStudentID
   ,Birthdate
   ,TicketStartedTime=StartTime
   ,CAST(RawScore AS int)                         AS RawScoreAll
   ,CAST(MaxRawScore AS int)                      AS MaxRawScoreAll
   ,CAST(CASE WHEN TestStatus = 'AllScoringComplete' THEN tetsAll.ScaleScore WHEN TestStatus = 'AutoScoringComplete' THEN AutoSc.ScaleScore ELSE -1 END AS int)  AS ScaleScoreAll
   ,ISNULL(CASE WHEN TestStatus = 'AllScoringComplete' THEN PerformanceLevel END, 'N/A')               AS PerformanceLevelAll
   ,cts.Name                                      AS TestSessionName
FROM        (SELECT AdministrationID, TestSessionID, Name, Test, Level, DistrictCode, SchoolCode FROM Core.TestSession) cts
CROSS APPLY (SELECT StudentID, DocumentID FROM TestSession.Links WHERE AdministrationID = cts.AdministrationID AND TestSessionID = cts.TestSessionID) tsl
CROSS APPLY (SELECT LastName, FirstName, CAST(BirthDate AS date) AS Birthdate, Gender, Grade, StateStudentID FROM Core.Student WHERE AdministrationID = cts.AdministrationID AND StudentID = tsl.StudentID) cs
CROSS APPLY (SELECT ContentArea FROM Scoring.Tests WHERE AdministrationID = cts.AdministrationID AND Test = cts.Test) st
OUTER APPLY (SELECT [Description], Level FROM Scoring.TestLevels WHERE AdministrationID = cts.AdministrationID AND Test = cts.Test AND Level = cts.Level) stl
CROSS APPLY (SELECT Form, UserName, Password, BaseDocumentID FROM Document.TestTicket WHERE AdministrationID = cts.AdministrationID AND DocumentID = tsl.DocumentID AND Test = cts.Test AND Level = cts.Level) dtt
CROSS APPLY (SELECT DISTINCT TestEventID, Form FROM Core.TestEvent WHERE AdministrationID = cts.AdministrationID AND DocumentID = ISNULL(dtt.BaseDocumentID, tsl.DocumentID) AND Test = cts.Test) cte
CROSS APPLY (SELECT RawScore, ISNULL(ScaleScore, -1) AS ScaleScore, PerformanceLevel, Score as removeScore FROM TestEvent.TestScores WHERE AdministrationID = cts.AdministrationID AND TestEventID = cte.TestEventID AND Test = cts.Test AND Score = @ScoreConfig) tetsAll
CROSS APPLY (SELECT CAST(Value AS numeric) AS MaxRawScore, Name FROM TestEvent.Extensions WHERE AdministrationID = cts.AdministrationID AND Test = cts.Test AND Name = 'MaxRawAttempted' + @ScoreConfig AND TestEventID = cte.TestEventID) teeAll
CROSS APPLY (SELECT SiteName AS DistrictName FROM Core.Site WHERE LevelID = 1 AND AdministrationID = cts.AdministrationID AND SiteCode = cts.DistrictCode) csdi
CROSS APPLY (SELECT SiteName AS SchoolName FROM Core.Site WHERE LevelID = 2 AND AdministrationID = cts.AdministrationID AND SiteCode = cts.SchoolCode AND SuperSiteCode = cts.DistrictCode) cssc
CROSS APPLY (SELECT TestStatus FROM TestEvent.TestStatus WHERE AdministrationID = cts.AdministrationID AND TestEventID = cte.TestEventID AND Test = cts.Test AND ((TestStatus = 'AutoScoringComplete') OR (TestStatus = 'AllScoringComplete'))) tetstat
OUTER APPLY (SELECT ScaleScore FROM TestEvent.TestScores WHERE AdministrationID=cts.AdministrationID and TestEventID=cte.TestEventID and Test=cts.Test and Score='AUTO') AutoSc
OUTER APPLY (SELECT MIN(CASE @EnforceLocalTimeZone WHEN 'Y' THEN LocalStartTime ELSE StartTime END) AS StartTime  FROM Document.TestTicketView WHERE AdministrationID = @_AdministrationID AND ((BaseDocumentID IS NOT NULL AND BaseDocumentID = dtt.BaseDocumentID) OR (BaseDocumentID IS NULL AND DocumentID=tsl.DocumentID))) tStartTime
WHERE cts.AdministrationID = @_AdministrationID
  AND DistrictCode     = @_DistrictCode 
  AND SchoolCode       = @_SchoolCode 
  AND cts.Test in (select Test from @Test)
  AND cts.Level in (select Level from @Level) 
  AND Grade            = @_Grade
  AND stl.Description  = @_AssessmentName;

END

GO
