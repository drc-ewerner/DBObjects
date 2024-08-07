USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportingRawScoreRosterV6]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[ReportingRawScoreRosterV6]
	@Administrationid int,
	@DistrictCode varchar(15),
	@SchoolCode varchar(15),
	@Grade varchar(2),
	@ContentArea varchar(50)
AS
BEGIN
declare @ScoreConfig varchar(1000)=eWeb.GetConfigExtensionValue(@Administrationid,'eWeb','Reporting.OnlineResults.ScoreSet','ALL');
declare @Test varchar(50)=(select Test from Scoring.Tests where AdministrationID=@AdministrationID and ContentArea=@ContentArea);
declare @levels TABLE ([Level] VARCHAR(20) PRIMARY KEY CLUSTERED([Level]))
INSERT INTO @levels([Level])
select Level from Scoring.TestLevelGrades where AdministrationID=@AdministrationID and Test=@Test and Grade=@Grade
select distinct
	AdministrationID,DistrictName,DistrictCode,SchoolName,SchoolCode,ContentArea,Grade,LastName,FirstName,StateStudentID,Birthdate,PointsEarned=cast(RawScore as int),PointsPossible=cast(MaxRawScore as int)  
from (select ts.AdministrationID,ts.TestSessionID,tfp.PartTest as Test,ts.Level,ts.DistrictCode,ts.SchoolCode, ts.Test AS ActualTest from Core.TestSession ts
		join scoring.TestSessionTicketParts tfp on ts.AdministrationID = tfp.AdministrationID and ts.test = tfp.test and ts.level = tfp.Level) cts
INNER JOIN @levels l ON l.[Level] = cts.[Level]
cross apply (select StudentID,DocumentID from TestSession.Links where AdministrationID=cts.AdministrationID and TestSessionID=cts.TestSessionID) tsl
cross apply (select LastName,FirstName,Birthdate=cast(BirthDate as date),Gender,Grade,StateStudentID from Core.Student where AdministrationID=cts.AdministrationID and StudentID=tsl.StudentID) cs
cross apply (select ContentArea from Scoring.Tests where AdministrationID=cts.AdministrationID and Test=cts.Test) st
cross apply (select Form,UserName,Password,BaseDocumentID from Document.TestTicket where AdministrationID=cts.AdministrationID and DocumentID=tsl.DocumentID and Test=cts.Test and Level=cts.Level) dtt
cross apply (select distinct TestEventID,Form from Core.TestEvent where AdministrationID=cts.AdministrationID and DocumentID=isnull(dtt.BaseDocumentID,tsl.DocumentID) and Test=cts.Test and Level=cts.Level) cte
cross apply (select RawScore from TestEvent.TestScores where AdministrationID=cts.AdministrationID and TestEventID=cte.TestEventID and Test=cts.Test and Score=@ScoreConfig) tets
cross apply (select cast(Value as numeric) MaxRawScore,Name from TestEvent.Extensions where AdministrationID=cts.AdministrationID and Test=cts.Test and Name='MaxRawAttempted'+@ScoreConfig and TestEventID=cte.TestEventID) tee
cross apply (select SiteName DistrictName from Core.Site where LevelID=1 and AdministrationID=cts.AdministrationID and SiteCode=cts.DistrictCode) csdi
cross apply (select SiteName SchoolName from Core.Site where LevelID=2 and AdministrationID=cts.AdministrationID and SiteCode=cts.SchoolCode and SuperSiteCode=cts.DistrictCode) cssc
cross apply (select TestStatus from TestEvent.TestStatus where AdministrationID=cts.AdministrationID and TestEventID=cte.TestEventID and Test=cts.Test and ((TestStatus='AutoScoringComplete') or (TestStatus='AllScoringComplete'))) tetstat
where 
	AdministrationID=@Administrationid and DistrictCode=@DistrictCode and SchoolCode=@SchoolCode and Grade=@Grade and (actualtest=@test or test=@test);
END
GO
