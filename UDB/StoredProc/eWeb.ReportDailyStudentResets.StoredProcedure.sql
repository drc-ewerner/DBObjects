USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportDailyStudentResets]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[ReportDailyStudentResets]

	@AdministrationID int,
	@StatusTime datetime,
	@DistrictCode varchar(15),
	@SchoolCode varchar(1000)
as
set nocount on; set transaction isolation level read uncommitted;

Declare @Threshold INTEGER

select @Threshold = value
from [Config].[Extensions] 
where [AdministrationID] = 0 and [Category] ='eWeb' and [Name] = 'Reporting.StudentResets.Threshold'

--Check  @Threshold
IF @Threshold is NULL
BEGIN 
		Declare @msg varchar (100)
		Set @msg = 'Config.extension, Reporting.StudentResets.Threshold, is not set for AdminId '+ Cast(@AdministrationId as varchar) +'.'
		
		RAISERROR (@msg, 16, 0);
		RETURN;
END

select 
	TS.DistrictCode,
	DistrictName=District.SiteName,
	TS.SchoolCode,
	SchoolName=School.SiteName,
	CS.Grade,
	CS.FirstName,
	CS.LastName,
	CS.StateStudentID,
	CS.DistrictStudentID,
	ST.ContentArea,
	STL.Description AS Assessment,
	ResetDate,
	ResetCount,
	CumulativeCount
from Document.TestTicket TT 
inner join TestSession.Links TL on TT.AdministrationID=TL.AdministrationID and TT.DocumentID=TL.DocumentID
inner join Core.TestSession TS on TL.AdministrationID=TS.AdministrationID and TL.TestSessionID=TS.TestSessionID
inner join Core.site District on District.AdministrationID=TS.AdministrationID and District.SiteCode=TS.DistrictCode and District.LevelID=1
inner join Core.Site School on School.AdministrationID=TS.AdministrationID and School.SiteCode=TS.SchoolCode and School.LevelID=2 and District.SiteCode = School.SuperSiteCode
inner join Scoring.Tests ST on ST.AdministrationID=TT.AdministrationID and ST.Test=TT.Test
inner join Core.Document CD on CD.AdministrationID=TT.AdministrationID and CD.DocumentID=TT.DocumentID
inner join Core.Student CS on CS.AdministrationID=CD.AdministrationID and CD.StudentID=CS.StudentID
inner join Scoring.TestLevels STL on STL.AdministrationID = TS.AdministrationID and STL.Level = TS.Level and STL.Test = TS.Test
cross apply (
	select ResetDate=convert(varchar,TTS1.Statustime,111),ResetCount=count(*)
	from Document.TestTicketStatus TTS1 
	where TTS1.AdministrationID=TT.AdministrationID and TTS1.DocumentID=TT.DocumentID and status='Unlocked'
	group by convert(varchar,TTS1.Statustime,111)
) TTS1
cross apply (
	select CumulativeCount=count(*) 
	from Document.TestTicketStatus TTS2 
	where TTS2.AdministrationID=TT.AdministrationID and TTS2.DocumentID=TT.DocumentID and status='Unlocked' and convert(varchar,TTS2.Statustime,111)<=TTS1.ResetDate
) TTS2  	
cross apply (
	select TotalCount=count(*) 
	from Document.TestTicketStatus TTS3 
	where TTS3.AdministrationID=TT.AdministrationID and TTS3.DocumentID=TT.DocumentID and status='Unlocked'
) TTS3  		
where TT.AdministrationID=@AdministrationID 
		and (TS.DistrictCode = @DistrictCode or @DistrictCode = '')
		and (TS.SchoolCode in (select * from dbo.fn_SplitSchoolList(@SchoolCode, '|')) or @SchoolCode = '')
		and TotalCount>@Threshold 
		and TTS1.ResetDate<=convert(varchar,@StatusTime,111) 
		and TS.DistrictCode not in ('88888', '412345678')	
order by TS.DistrictCode, TS.SchoolCode, CS.Grade, ST.ContentArea, Assessment, CS.LastName, CS.FirstName

GO
