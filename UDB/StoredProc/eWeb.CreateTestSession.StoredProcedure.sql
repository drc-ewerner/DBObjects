USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[CreateTestSession]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[CreateTestSession]
	@AdministrationID  int,
	@DistrictCode varchar(15),
	@SchoolCode varchar(15),
	@Test varchar(50),
	@Level varchar(20),
	@Mode varchar(50), 
	@StartTime datetime,
	@EndTime datetime,
	@Name varchar(100),
	@TestWindow varchar(20), 
	@ScheduleSource varchar(20),
	@TestMonitoring varchar(50) = NULL,
	@RestrictedAccess varchar(50) = NULL
as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

if (@TestWindow is null) begin

	select top(1) @TestWindow=tw.TestWindow,@ScheduleSource=case when SchoolCode='' then 'District' else 'School' end,@StartTime=isnull(@StartTime,StartDate),@EndTime=isnull(@EndTime,EndDate)
	from Site.TestWindows  tw
	join Admin.AssessmentSchedule  s  on tw.AdministrationID = s.AdministrationID and tw.TestWindow = s.TestWindow
	where tw.AdministrationID=@AdministrationID and DistrictCode=@DistrictCode and SchoolCode in (@SchoolCode,'')
	and s.Test=@Test and s.Level=@Level
	order by SchoolCode desc;

	select top(1) @TestWindow=isnull(@TestWindow,tw.TestWindow),@ScheduleSource=isnull(@ScheduleSource,'Default'),@StartTime=isnull(@StartTime,s.StartDate),@EndTime=isnull(@EndTime,s.EndDate)
	from Admin.TestWindow  tw
	join Admin.AssessmentSchedule  s  on tw.AdministrationID = s.AdministrationID and tw.TestWindow = s.TestWindow
	where tw.AdministrationID=@AdministrationID and (tw.TestWindow=@TestWindow or IsDefault=1)
	and s.Test=@Test and s.Level=@Level
	order by IsDefault desc;

end;

declare @TestSessionID int=next value for Core.TestSession_SeqEven;

insert Core.TestSession (AdministrationID,TestSessionID,DistrictCode,SchoolCode,Test,Level,StartTime,EndTime,Name,Mode,TestWindow,ScheduleSource, TestMonitoring,TestAccessControl)
select @AdministrationID,@TestSessionID,@DistrictCode,@SchoolCode,@Test,@Level,@StartTime,@EndTime,@Name,@Mode,@TestWindow,@ScheduleSource,NULLIF(@TestMonitoring, ''), NULLIF(@RestrictedAccess, '');
           
select TestSessionID=cast(@TestSessionID as decimal);
GO
