USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[JobDailyExcessiveLogins]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [eWeb].[JobDailyExcessiveLogins]

as

begin

--wrapped original SELECT statement in a SELECT-to-temp table statement. TA - 04/18/16
SELECT *
INTO #Temp_Excessive_Logins
FROM
(
	SELECT 
	TT.AdministrationID
	,TS.DistrictCode 
	,TS.SchoolCode 
	,cs.StudentID
	,LoggedinDate
	,TT.Form,ts.TestSessionID
	,District.SiteName AS DistrictName
	,School.SiteName AS SchoolName
	,CS.Grade
	,CS.FirstName
	,CS.LastName
	,CS.StateStudentID
	,CS.DistrictStudentID
	,ST.ContentArea
	,DayLogins 
	,TotalLogins
	,AllTotalLogins
	FROM Document.TestTicket TT 
	inner join TestSession.Links TL ON TT.AdministrationID = TL.AdministrationID and TT.DocumentID = TL.DocumentID
	inner join Core.TestSession TS ON TL.AdministrationID = TS.AdministrationID and TL.TestSessionID = TS.TestSessionID
	inner join Core.site District ON District.AdministrationID = TS.AdministrationID and District.SiteCode = TS.DistrictCode and District.LevelID = 1
	inner join Core.Site School ON School.AdministrationID = TS.AdministrationID and School.SiteCode = TS.SchoolCode and School.LevelID = 2 and District.SiteCode = School.SuperSiteCode
	inner join Scoring.Tests ST ON ST.AdministrationID = TT.AdministrationID and ST.Test = TT.Test
	inner join Core.Document CD ON CD.AdministrationID = TT.AdministrationID and CD.DocumentID = TT.DocumentID
	inner join Core.Student CS ON CS.AdministrationID = CD.AdministrationID and CD.StudentID = CS.StudentID
	cross apply (SELECT CAST(StatusTime as date) as LoggedinDate
						,DayLogins = COUNT(*)
						 FROM Document.TestTicketStatus TTS1 
						 WHERE TTS1.AdministrationID = TT.AdministrationID and TTS1.DocumentID = TT.DocumentID
						 and status = 'In Progress'
						 Group by cast(StatusTime as date)) TTS1
	cross apply (SELECT TotalLogins = COUNT(*) 
						FROM Document.TestTicketStatus TTS2 
						WHERE TTS2.AdministrationID = TT.AdministrationID and TTS2.DocumentID = TT.DocumentID
						and status = 'In Progress'
						and CAST(StatusTime as date) <= TTS1.LoggedinDate) TTS2 
	cross apply (SELECT AllTotalLogins = COUNT(*) 
						FROM Document.TestTicketStatus TTS3 
						WHERE TTS3.AdministrationID = TT.AdministrationID and TTS3.DocumentID = TT.DocumentID
						and status = 'In Progress') TTS3 		
			
	WHERE AllTotalLogins > 1
			and District.SiteName not like 'sample%' and LoggedinDate > isnull((select MAX(LoggedinDate) from [eWeb].[DailyExcessiveLoginsTable]),cast('' as date))
			and LoggedinDate<=DATEADD(day,-1,cast(getdate() as date))
) AS fillTempTable

--new SELECT from the new temp table, in order to fill the DailyExcessiveLoginsTable without any PK violations. TA - 04/18/16
INSERT INTO [eWeb].[DailyExcessiveLoginsTable]
SELECT AdministrationID, DistrictCode, SchoolCode, StudentID, LoggedinDate, Form, TestSessionID,
			DistrictName, SchoolName, Grade, FirstName, LastName, StateStudentID, DistrictStudentID, ContentArea, 
			SUM(DayLogins) AS DL, SUM(TotalLogins) AS TL, SUM(AllTotalLogins) as ATL 
FROM #Temp_Excessive_Logins
GROUP BY AdministrationID, DistrictCode, SchoolCode, StudentID, LoggedinDate, Form, TestSessionID,
			DistrictName, SchoolName, Grade, FirstName, LastName, StateStudentID, DistrictStudentID, ContentArea

--drop the temporary table when finished
DROP TABLE #Temp_Excessive_Logins

END
GO
