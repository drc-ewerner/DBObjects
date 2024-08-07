USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportDailyExcessiveLogins]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[ReportDailyExcessiveLogins]
	@AdministrationID INTEGER,
	@StatusTime DATETIME,
	@DistrictCode varchar(15),
	@SchoolCode VARCHAR(1000)
AS
BEGIN

Declare @Threshold INTEGER

select @Threshold = value
from [Config].[Extensions] 
where [AdministrationID] = 0 and [Category] ='eWeb' and [Name] = 'Reporting.ExcessiveLogins.Threshold'

--Check  @Threshold
IF @Threshold is NULL
BEGIN 
		Declare @msg varchar (100)
		Set @msg = 'Config.extension, Reporting.ExcessiveLogins.Threshold, is not set for AdminId '+ Cast(@AdministrationId as varchar) +'.'
		
		RAISERROR (@msg, 16, 0);
		RETURN;
END

SELECT 
	EL.DistrictCode 
	,DistrictName
	,EL.SchoolCode 
	,SchoolName
	,Grade
	,FirstName
	,LastName
	,StateStudentID
	,DistrictStudentID
	,ContentArea
	,STL.Description AS Assessment
	,EL.Form
	,LoggedinDate
	,DayLogins 
	,TotalLogins
FROM [eWeb].[DailyExcessiveLoginsTable] EL
inner join Core.TestSession TS on EL.AdministrationID = TS.AdministrationID and EL.TestSessionID = TS.TestSessionID
inner join Scoring.TestLevels STL on STL.AdministrationID = TS.AdministrationID and STL.Level = TS.Level and STL.Test = TS.Test
where EL.AdministrationID=@AdministrationID and 
LoggedinDate<=CAST(@StatusTime as date) and (EL.DistrictCode = @DistrictCode or @DistrictCode = '') 
and (EL.SchoolCode in (select * from dbo.fn_SplitSchoolList(@SchoolCode, '|')) or @SchoolCode = '')
and AllTotalLogins > @Threshold

END
GO
