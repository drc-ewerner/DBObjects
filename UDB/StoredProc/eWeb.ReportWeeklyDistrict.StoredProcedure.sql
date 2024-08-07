USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportWeeklyDistrict]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[ReportWeeklyDistrict]
	@AdministrationID integer,
	@DistrictCode varchar(15),
	@SchoolCode varchar(1000)
AS
BEGIN

SELECT 
	TS.DistrictCode 
	,S.SiteName
	,DATEPART(yyyy,TT.StartTime) AS Year
	,DATEPART(WK,TT.StartTime) as Week
	,COUNT(tt.starttime) as TestsStarted
	,COUNT(tt.EndTime) as TestsEnded
FROM Document.TestTicketView TT 
inner join TestSession.Links TL on TT.AdministrationID = TL.AdministrationID and TT.DocumentID = TL.DocumentID
inner join Core.TestSession TS on TL.AdministrationID = TS.AdministrationID and TL.TestSessionID = TS.TestSessionID
inner join Core.site S on S.AdministrationID = TS.AdministrationID and S.SiteCode = TS.DistrictCode and S.LevelID = 1
WHERE TT.Status <>'Not Started'
		and TT.AdministrationID = @AdministrationID
		and (TS.DistrictCode = @DistrictCode or @DistrictCode = '')
		and (TS.SchoolCode IN (select * from dbo.fn_SplitSchoolList(@SchoolCode, '|')) or @SchoolCode = '')
		and TS.DistrictCode not in ('88888', '412345678')	 
GROUP BY DistrictCode,Sitename,DATEPART(yyyy,TT.StartTime),DATEPART(WK,TT.StartTime)

END
GO
