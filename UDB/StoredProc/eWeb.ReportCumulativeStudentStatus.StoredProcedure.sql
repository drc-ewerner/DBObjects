USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportCumulativeStudentStatus]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [eWeb].[ReportCumulativeStudentStatus]
	@AdministrationID int,
	@DistrictCode varchar(15),
	@SchoolCode varchar(1000)

AS
BEGIN
	set nocount on; set transaction isolation level read uncommitted;

	-- Lookup timezone offset
	declare @Offset as int,
		@NotLock varchar(1000),
		@UseStudentExtNTC BIT,
		@StudentExtNTCName VARCHAR(1000)

	select @Offset=eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','Timezone.Offset',NULL)
	select @NotLock=eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','Tickets.PreventLock','NULL')
	select @StudentExtNTCName = ISNULL(eWeb.GetConfigExtensionValue(@AdministrationID, 'eWeb', 'Report.CumulativeStudentStatus_StudentExtNTCName', ''), '')

	if @NotLock='NULL' set @NotLock=NULL

	declare @t table (AccommodationType varchar(250),Category varchar(250),Name varchar(250), DisplayName varchar(250), GroupName varchar(250))
		DECLARE @Table TABLE(
			[ContentArea] varchar(50)
		)
		INSERT INTO @Table
		EXECUTE eweb.getcontentareas @AdministrationID

		SET NOCOUNT ON;
	insert into @t
		SELECT substring(n.name,0,charindex('.',n.name)) AccomodationType,n.Category, n.Name, DisplayName, ISNULL(GroupName, DisplayName) AS GroupName
		FROM [XRef].[StudentExtensionValues] val
			INNER JOIN [XRef].[StudentExtensionNames] n ON val.AdministrationID = n.AdministrationId and val.Category = n.Category and val.Name = n.Name
			inner join Scoring.Tests te on val.AdministrationID = te.AdministrationID and val.Category = te.ContentArea
	where charindex('.',n.name) <> 0 and n.AdministrationId = @AdministrationID 
			AND n.Category in (Select ContentArea from @Table)
			and isnull(n.DisplayOrder,0) >= 0
	group by ISNULL(GroupName, DisplayName), DisplayName, n.Name,n.category,substring(n.name,0,charindex('.',n.name)), n.DisplayOrder 

	select 
		District=s.DistrictCode,
		School=s.SchoolCode,
		DistrictName=dn.SiteName,
		SchoolName=sn.SiteName,
		Subject=st.ContentArea,
		STL.Description AS Assessment,
		Grade,
		StateID=StateStudentID,
		DistrictID=DistrictStudentID,
		LastName,
		FirstName,
		MiddleInitial=convert(char(1),left(MiddleName,1)),
		DateOfBirth=left(convert(varchar,BirthDate,120),10),
		Locked=case when @NotLock is null then case when t.Status='In Progress' and datediff(d,isnull(t.UnlockTime,t.StartTime),getdate())>=1 then 'Y' else 'N' end else 'N' end,
		Status=case when @NotLock is null then case when t.Status='In Progress' and datediff(d,isnull(t.UnlockTime,t.StartTime),getdate())>=1 then 'Locked' else t.Status end else t.Status end,
		Invalidated=case when NotTestedCode='DN' then 'Y' else 'N/A' end,
		CASE
			WHEN @StudentExtNTCName = '' THEN t.NotTestedCode
			ELSE ISNULL(ntc.Value, '')
		END AS NotTestedCode,
		Accommodations=isnull(x.AccomName,'N/A'),
		AltAssessment='',
		PartName='#' + isnull(PartName,'1'),
		DATEADD(hh, @Offset, t.[StartTime]) as StartTime,
		DATEADD(hh, @Offset, t.[EndTime]) as EndTime,
		Convert(varchar,DATEADD(hh, @Offset, t.[StartTime])) as StartTimeStr,
		Convert(varchar,DATEADD(hh, @Offset, t.[EndTime])) as EndTimeStr,
		t.[LocalStartTime], 
		t.[LocalEndTime], 
		DATEDIFF(hh,t.[StartTime],t.[LocalStartTime]) AS LocalOffset,
		t.Timezone
	from Document.TestTicketView t
	inner join TestSession.Links d on d.AdministrationID=t.AdministrationID and d.DocumentID=t.DocumentID
	inner join Scoring.Tests st on st.AdministrationID=t.AdministrationID and st.Test=t.Test
	inner join Core.Student s on s.AdministrationID=t.AdministrationID and s.StudentID=d.StudentID
	left outer join Student.Extensions ntc
		ON ntc.AdministrationID = s.AdministrationID
			AND ntc.StudentID = s.StudentID
			AND ntc.Category = 'TestingCodes'
			AND ntc.Name = REPLACE(REPLACE(@StudentExtNTCName, '{Test}', t.Test), '{Level}', t.[Level])
	inner join Core.TestSession TS on d.AdministrationID = TS.AdministrationID and d.TestSessionID = TS.TestSessionID
	inner join Scoring.TestLevels STL on STL.AdministrationID = TS.AdministrationID and STL.Level = TS.Level and STL.Test = TS.Test
	outer apply (select stuff((select ',' + a.DisplayName  from Student.Extensions e 
					inner join @t a on e.Category=a.Category and e.Name=a.Name
					where s.AdministrationID=e.AdministrationID and s.StudentID=e.StudentID and st.ContentArea=e.Category
					--and exists (select * from @t a where e.Category=a.Category and e.Name=a.Name) 
					and e.Value='Y' 
					for xml path('')),1,1,'') as AccomName) x
	inner join Core.Site dn on s.AdministrationID=dn.AdministrationID and s.DistrictCode=dn.SiteCode
	inner join Core.Site sn on s.AdministrationID=sn.AdministrationID and s.DistrictCode=sn.SuperSiteCode and s.SchoolCode=sn.SiteCode
	where t.AdministrationID=@AdministrationID 
			and (s.DistrictCode = @DistrictCode or @DistrictCode = '')
			and (s.SchoolCode in (select * from dbo.fn_SplitSchoolList(@SchoolCode, '|')) or @SchoolCode = '')
			and s.DistrictCode not in ('88888', '412345678')	
			and dn.LevelID=1
	order by s.DistrictCode,s.SchoolCode,Grade,LastName,FirstName,StateStudentID,ContentArea, Assessment, PartName

END

GO
