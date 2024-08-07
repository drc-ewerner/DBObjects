USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportTestingStatusBySchool]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[ReportTestingStatusBySchool]
	@AdministrationID integer,
	@StatusTime datetime,
	@DistrictCode varchar(15),
	@SchoolCode varchar(1000)
AS
BEGIN

SELECT 
DistrictCode 
,DistrictName
,SchoolCode 
,SchoolName
,Grade
,Subject
,TestsStarted
,TestsEnded
FROM eWeb.TestingStatusBySchoolTable
where AdministrationID=@AdministrationID and (DistrictCode = @DistrictCode or @DistrictCode = '') 
and (SchoolCode IN (select * from dbo.fn_SplitSchoolList(@SchoolCode, '|')) or @SchoolCode = '') 
and TestDate=cast(@StatusTime as date)
END
GO
