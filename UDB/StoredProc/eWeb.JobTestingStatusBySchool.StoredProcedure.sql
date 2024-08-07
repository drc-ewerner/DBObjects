USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[JobTestingStatusBySchool]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[JobTestingStatusBySchool]
AS

begin

with q as
(
SELECT 
tt.AdministrationID,
TS.DistrictCode 
,TS.SchoolCode 
,ST.ContentArea as Subject
,isnull(CS.Grade,'') Grade
,CAST(tt.StartTime as date) TestDate
,District.SiteName as DistrictName
,School.SiteName as SchoolName
,COUNT(*) as TestsStarted
,TestsEnded=0

FROM Document.TestTicketView TT 
inner join TestSession.Links TL on TT.AdministrationID = TL.AdministrationID and TT.DocumentID = TL.DocumentID
inner join Core.TestSession TS on TL.AdministrationID = TS.AdministrationID and TL.TestSessionID = TS.TestSessionID
inner join Core.site District on District.AdministrationID = TS.AdministrationID and District.SiteCode = TS.DistrictCode and District.LevelID = 1
inner join Core.Site School on School.AdministrationID = TS.AdministrationID and School.SiteCode = TS.SchoolCode and School.SuperSiteCode=TS.DistrictCode and School.LevelID = 2
inner join Scoring.Tests ST on ST.AdministrationID = TT.AdministrationID and ST.Test = TT.Test
inner join Core.Document CD on CD.AdministrationID = TT.AdministrationID and CD.DocumentID = TT.DocumentID
inner join Core.Student CS on CS.AdministrationID = CD.AdministrationID and CD.StudentID = CS.StudentID
WHERE TT.Status <>'Not Started'
		and District.SiteName not like 'sample%'  and tt.StartTime is not null
		and cast(TT.StartTime as date) >isnull((select MAX(TestDate) from [eWeb].[TestingStatusBySchoolTable]),cast('' as date))
		and CAST(tt.StartTime as date)<=DATEADD(day,-1,cast(getdate() as date))

GROUP BY TT.AdministrationID, ts.Districtcode,District.SiteName,ts.Schoolcode,School.SiteName,CS.Grade,ST.ContentArea,
tt.StartTime

union all

SELECT 
tt.AdministrationID,
TS.DistrictCode 
,TS.SchoolCode 
,ST.ContentArea as Subject
,isnull(CS.Grade,'') Grade
,CAST(tt.EndTime as date) TestDate
,District.SiteName as DistrictName
,School.SiteName as SchoolName
,TestsStarted=0
,COUNT(*) as TestsEnded

FROM Document.TestTicketView TT 
inner join TestSession.Links TL on TT.AdministrationID = TL.AdministrationID and TT.DocumentID = TL.DocumentID
inner join Core.TestSession TS on TL.AdministrationID = TS.AdministrationID and TL.TestSessionID = TS.TestSessionID
inner join Core.site District on District.AdministrationID = TS.AdministrationID and District.SiteCode = TS.DistrictCode and District.LevelID = 1
inner join Core.Site School on School.AdministrationID = TS.AdministrationID and School.SiteCode = TS.SchoolCode and School.SuperSiteCode=TS.DistrictCode and School.LevelID = 2
inner join Scoring.Tests ST on ST.AdministrationID = TT.AdministrationID and ST.Test = TT.Test
inner join Core.Document CD on CD.AdministrationID = TT.AdministrationID and CD.DocumentID = TT.DocumentID
inner join Core.Student CS on CS.AdministrationID = CD.AdministrationID and CD.StudentID = CS.StudentID
WHERE TT.Status <>'Not Started'
		and District.SiteName not like 'sample%' and tt.EndTime is not null
		and cast(TT.EndTime as date) >isnull((select MAX(TestDate) from [eWeb].[TestingStatusBySchoolTable]),cast('' as date))
		and CAST(tt.EndTime as date)<=DATEADD(day,-1,cast(getdate() as date))

GROUP BY TT.AdministrationID, ts.Districtcode,District.SiteName,ts.Schoolcode,School.SiteName,CS.Grade,ST.ContentArea,
tt.EndTime

)

insert into [eWeb].[TestingStatusBySchoolTable]


SELECT AdministrationID,DistrictCode,SchoolCode,Subject,Grade, TestDate ,DistrictName ,SchoolName
,TestsStarted=sum(TestsStarted),TestsEnded=sum(TestsEnded) from q 
group by administrationid,districtcode,districtname,schoolcode,schoolname,grade,subject,TestDate

end
GO
