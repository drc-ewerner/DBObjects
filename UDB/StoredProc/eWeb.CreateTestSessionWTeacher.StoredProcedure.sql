USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[CreateTestSessionWTeacher]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[CreateTestSessionWTeacher]
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
	@TeacherID int,
	@ClassCode varchar(15) = '',
	@ScoringOption VARCHAR(50) = NULL,
	@OptionalItems VARCHAR(50) = NULL,
	@TestMonitoring varchar(50) = NULL,
	@RestrictedAccess varchar(50) = NULL
as

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

if (@TestWindow is null) begin

	select top(1) @TestWindow=TestWindow,@ScheduleSource=case when SchoolCode='' then 'District' else 'School' end
	from Site.TestWindows
	where AdministrationID=@AdministrationID and DistrictCode=@DistrictCode and SchoolCode in (@SchoolCode,'')
	order by SchoolCode desc;

	select top(1) @TestWindow=isnull(@TestWindow,TestWindow),@ScheduleSource=isnull(@ScheduleSource,'Default'),@StartTime=isnull(@StartTime,StartDate),@EndTime=isnull(@EndTime,EndDate)
	from Admin.TestWindow
	where AdministrationID=@AdministrationID and (TestWindow=@TestWindow or IsDefault=1)
	order by IsDefault desc;

end;

declare @TestSessionID int=next value for Core.TestSession_SeqEven;

insert Core.TestSession (AdministrationID,TestSessionID,DistrictCode,SchoolCode,Test,Level,StartTime,EndTime,Name,Mode,TestWindow,ScheduleSource,TeacherID,ClassCode,ScoringOption,OptionalItems,TestMonitoring,TestAccessControl)
select @AdministrationID,@TestSessionID,@DistrictCode,@SchoolCode,@Test,@Level,@StartTime,@EndTime,@Name,@Mode,@TestWindow,@ScheduleSource,(case when @teacherID=0 then null else @teacherID end), @ClassCode
	,CASE WHEN @ScoringOption IS NOT NULL AND @ScoringOption <> '' THEN @ScoringOption ELSE NULL END
	,NULLIF(@OptionalItems, ''), NULLIF(@TestMonitoring, ''), NULLIF(@RestrictedAccess, '');
           
select TestSessionID=cast(@TestSessionID as decimal);
GO
