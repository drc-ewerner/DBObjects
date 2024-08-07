USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportDailyStudentStatus]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE procedure [eWeb].[ReportDailyStudentStatus]
		@AdministrationID int,
		@StatusTime datetime,
		@DistrictCode varchar(15),
		@SchoolCode varchar(1000)
	as
	set nocount on; set transaction isolation level read uncommitted;

	-- Lookup timezone offset
	declare @Offset as int
	select @Offset=eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','Timezone.Offset',NULL)

	select 
		District=s.DistrictCode,
		School=s.SchoolCode,
		Subject=ContentArea,
		STL.Description AS Assessment,
		Grade,
		StateID=StateStudentID,
		DistrictID=DistrictStudentID,
		LastName,
		FirstName,
		MiddleInitial=convert(char(1),left(MiddleName,1)),
		DateOfBirth=convert(varchar,BirthDate,101),
		Invalidated=case when NotTestedCode='DN' then 'Yes' else '' end,
		NotTestedCode,
		DATEADD(hh, @Offset, [StartTime]) as StartTime,
		DATEADD(hh, @Offset, [EndTime]) as EndTime,
		Convert(varchar,DATEADD(hh, @Offset, [StartTime])) as StartTimeStr,
		Convert(varchar,DATEADD(hh, @Offset, [EndTime])) as EndTimeStr,
		t.[LocalStartTime], 
		t.[LocalEndTime], 
		DATEDIFF(hh,t.[StartTime],t.[LocalStartTime]) AS LocalOffset,
		t.Timezone
	from Document.TestTicketView t
	inner join Core.Document d on d.AdministrationID=t.AdministrationID and d.DocumentID=t.DocumentID
	inner join Core.Student s on s.AdministrationID=t.AdministrationID and s.StudentID=d.StudentID
	inner join Scoring.Tests st on st.AdministrationID=t.AdministrationID and st.Test=t.Test
	inner join Scoring.TestLevels STL on STL.AdministrationID = t.AdministrationID and STL.Level = t.Level and STL.Test = t.Test
	where t.AdministrationID=@AdministrationID 
			and (s.DistrictCode = @DistrictCode or @DistrictCode = '')
			and (s.SchoolCode in (select * from dbo.fn_SplitSchoolList(@SchoolCode, '|')) or @SchoolCode = '')
			and convert(varchar,@StatusTime,101) in (convert(varchar,StartTime,101),convert(varchar,EndTime,101))
			and s.DistrictCode not in ('88888', '412345678')	
	order by s.DistrictCode,s.SchoolCode,ContentArea, Assessment, Grade,StateStudentID

;

GO
