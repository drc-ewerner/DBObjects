USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportExcessiveLoginsPerTest]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/********************************************************
 * Date: 07/10/2015
 * GL:  Remove @Threshold from the parameters
 * BUG: ED-123: Refactor the Code for Status Reports
 ********************************************************/
CREATE procedure  [eWeb].[ReportExcessiveLoginsPerTest] 
	@AdministrationID INTEGER,
	@StatusTime DATETIME,
	@DistrictCode VARCHAR(15),
	@SchoolCode VARCHAR(1000)
AS
BEGIN

set nocount on; 

declare @Assessment varchar(500)

select @Assessment = Year + ' ' + Season + ' ' + LongDescription 
From Core.Administration Where AdministrationID = @AdministrationID

Declare @Threshold INTEGER

select @Threshold = value
from [Config].[Extensions] 
where [AdministrationID] = 0 and [Category] ='eWeb' and [Name] = 'Reporting.ExcessiveLoginsPerTest.Threshold'

--Check  @Threshold
IF @Threshold is NULL
BEGIN 
		Declare @msg varchar (100)
		Set @msg = 'Config.extension, Reporting.ExcessiveLoginsPerTest.Threshold, is not set for AdminId '+ Cast(@AdministrationId as varchar) +'.'
		
		RAISERROR (@msg, 16, 0);
		RETURN;
END

CREATE TABLE #Tickets 
    (
		AdministrationID int,
		DocumentID int,
		Test varchar(50),
		Level varchar(20),
		UserName varchar(20),
		Form varchar(20),
		PartName varchar(50),
		DistrictCode varchar(15),
		SchoolCode varchar(15),
		StudentID int,
		MainTest varchar(50),
		MainLevel varchar(20),
		WhereFrom char(1)
		--primary key clustered (AdministrationID, TestEventID, Test, ItemID)
    );

insert into #Tickets
SELECT	TT.AdministrationID,
		TT.DocumentID,
		TT.Test,
		TT.Level,
		TT.UserName,
		TT.Form,
		TT.PartName,
		TS.DistrictCode,
		TS.SchoolCode,
		TL.StudentID,
		CASE When SSTP.PartTest Is Null Then TT.Test Else SSTP.Test END,
		CASE When SSTP.PartLevel Is Null Then TT.Level Else SSTP.Level END,
		'T'
FROM Core.Administration AD
inner join Document.TestTicket TT ON AD.AdministrationID = TT.AdministrationID
inner join TestSession.Links TL ON TT.AdministrationID = TL.AdministrationID and TT.DocumentID = TL.DocumentID
inner join Core.TestSession TS ON TL.AdministrationID = TS.AdministrationID and TL.TestSessionID = TS.TestSessionID
left join Scoring.TestSessionTicketParts SSTP ON TT.AdministrationID = SSTP.AdministrationID and TT.Test = SSTP.PartTest and TT.Level = SSTP.PartLevel and TT.PartName = SSTP.PartName
WHERE TT.AdministrationID = @AdministrationID 
		and (TS.DistrictCode = @DistrictCode or @DistrictCode = '')
		and (TS.SchoolCode in (select * from dbo.fn_SplitSchoolList(@SchoolCode, '|')) or @SchoolCode = '')
		and TS.DistrictCode not in ('88888', '412345678')

insert into #Tickets
SELECT	TT.AdministrationID,
		TT.DocumentID,
		TT.Test,
		TT.Level,
		TT.UserName,
		TT.Form,
		TT.PartName,
		R.DistrictCode,
		R.SchoolCode,
		R.StudentID,
		R.MainTest,
		R.MainLevel,
		'R'
FROM #Tickets R
INNER JOIN Document.TestTicket TT
ON R.AdministrationID = TT.AdministrationID And R.UserName = TT.UserName And R.Test = TT.Test And
	R.Level = TT.Level And isnull(R.PartName,'') = isnull(TT.PartName,'')
WHERE TT.NotTestedCode Is Not Null


CREATE CLUSTERED INDEX [ix_Admin_Document]
ON [#Tickets] ([AdministrationID],[DocumentID],[StudentID],[Test],[Level],[UserName],[PartName])

CREATE TABLE #TicketStatus 
    (
		AdministrationID int,
		DocumentID int,
		Test varchar(50),
		Level varchar(20),
		UserName varchar(20),
		PartName varchar(50),
		StatusTime datetime,
		Status varchar(50)
		--primary key clustered (AdministrationID, TestEventID, Test, ItemID)
    );

INSERT INTO #TicketStatus
SELECT T.AdministrationID, T.DocumentID, T.Test, T.Level, T.UserName, T.PartName, S.StatusTime, S.Status
FROM #Tickets T
INNER JOIN Document.TestTicketStatus S
ON T.AdministrationID = S.AdministrationID And T.DocumentID = S.DocumentID
WHERE S.Status = 'In Progress';

CREATE NONCLUSTERED INDEX [ix_Admin_Document4]
ON #TicketStatus ([AdministrationID],[Test],[Level],[UserName],[PartName])

;
WITH ExcessiveLoginData as (
SELECT	T.DistrictCode,
		District.SiteName AS DistrictName,
		T.SchoolCode,
		School.SiteName AS SchoolName,
		CS.Grade,
		CS.FirstName,
		CS.LastName,
		CS.StateStudentID,
		CS.DistrictStudentID,
		ST.ContentArea,
		TL.Description AS Assessment,
		CASE When FP.Form Is Null Then T.Form Else FP.Form END AS Form,
		T.PartName,
		T.UserName,
		T.Test,
		T.Level,
		LoggedinDate,
		DayLogins,
		TotalLogins,
		MetToday,
		FirstMetDate,
		CompareLoggedinDate
FROM #tickets T
inner join Core.site District ON District.AdministrationID = T.AdministrationID and District.SiteCode = T.DistrictCode and District.LevelID = 1
inner join Core.Site School ON School.AdministrationID = T.AdministrationID and School.SiteCode = T.SchoolCode and School.LevelID = 2 AND School.SuperSiteCode = T.DistrictCode
inner join Scoring.Tests ST ON ST.AdministrationID = T.AdministrationID and ST.Test = T.Test
inner join Scoring.TestLevels TL ON TL.AdministrationID = ST.AdministrationID and TL.Test = T.MainTest and TL.Level = T.MainLevel 
left join Scoring.TestFormParts FP ON FP.AdministrationID = ST.AdministrationID and FP.Test =ST.Test and FP.FormPart = T.Form
--inner join Core.Document CD ON CD.AdministrationID = TT.AdministrationID and CD.DocumentID = TT.DocumentID
inner join Core.Student CS ON CS.AdministrationID = T.AdministrationID and CS.StudentID = T.StudentID
cross apply (SELECT CONVERT(VARCHAR,TTS1.Statustime,101)as LoggedinDate
					,CONVERT(VARCHAR,TTS1.Statustime,112)as CompareLoggedinDate
					,DayLogins = COUNT(*)
                     FROM #TicketStatus TTS1 
                     WHERE TTS1.AdministrationID = T.AdministrationID and TTS1.UserName = T.UserName and
						   TTS1.Test = T.Test and TTS1.Level = T.Level and isnull(TTS1.PartName,'') = isnull(T.PartName,'')
                     and status = 'In Progress'
                     Group by CONVERT(VARCHAR,TTS1.Statustime,101),CONVERT(VARCHAR,TTS1.Statustime,112)) TTS1
cross apply (SELECT TotalLogins = COUNT(*),
					MetToday = Case When COUNT(*) > @Threshold Then 'Yes' Else 'No' End,
					FirstMetDate = Case When COUNT(*) > @Threshold Then TTS1.LoggedinDate End
                    FROM #TicketStatus TTS2 
                    WHERE TTS2.AdministrationID = T.AdministrationID and TTS2.UserName = T.UserName and
						  TTS2.Test = T.Test and TTS2.Level = T.Level and isnull(TTS2.PartName,'') = isnull(T.PartName,'')
                    and status = 'In Progress'
                    and CONVERT(VARCHAR,TTS2.Statustime,112) <= TTS1.CompareLoggedinDate) TTS2 
cross apply (SELECT AllTotalLogins = COUNT(*) 
                    FROM #TicketStatus TTS3 
                    WHERE TTS3.AdministrationID = T.AdministrationID and TTS3.UserName = T.UserName and
						  TTS3.Test = T.Test and TTS3.Level = T.Level and isnull(TTS3.PartName,'') = isnull(T.PartName,'')
                    and status = 'In Progress') TTS3
WHERE T.WhereFrom = 'T'
		and AllTotalLogins > @Threshold
		and TTS1.CompareLoggedinDate <= CONVERT(VARCHAR,@StatusTime,112)
)
,GetThresholdDate AS (
SELECT UserName, Test, Level, PartName, MIN(FirstMetDate) AS ThresholdDate
FROM ExcessiveLoginData 
WHERE MetToday = 'Yes'
GROUP BY UserName, Test, Level, PartName)

SELECT	LD.DistrictCode, 
		LD.DistrictName,
		LD.SchoolCode,
		LD.SchoolName,
		LD.Grade,
		LD.FirstName,
		LD.LastName,
		LD.StateStudentID,
		LD.DistrictStudentID,
		LD.ContentArea,
		LD.Assessment,
		LD.Form,
		LD.PartName AS PartNumber,
		LD.LoggedinDate,
		LD.DayLogins, 
		LD.TotalLogins,
		TD.ThresholdDate,
		LD.CompareLoggedinDate,
		td.username,
		td.test,
		td.level
FROM ExcessiveLoginData LD
INNER JOIN GetThresholdDate TD
ON LD.UserName = TD.UserName And LD.Test = TD.Test And LD.Level = TD.Level And isnull(LD.PartName,'') = isnull(TD.PartName,'')
LEFT OUTER JOIN Xref.Grades xg
	ON xg.AdministrationID = @AdministrationID AND xg.Grade = LD.Grade
Order By LD.DistrictCode, LD.SchoolCode, xg.DisplayOrder, LD.ContentArea, LD.Assessment,
LD.LastName, LD.FirstName, LD.StateStudentID, PartNumber, LD.CompareLoggedinDate

drop table #Tickets
drop table #TicketStatus
END
GO
