USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestSessions3]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*  *****************************************************************
    * Description:  This proc returns a list of Test sessions
    *================================================================
    * Created:      ?
    * Developer:    ?
    *================================================================
    * Changes:
    *
	* Date:         09/12/18
    * Developer:    Priya Srinivasan
    * Description:  Added the @FromDate, @ToDate, @minFromDate and @maxToDate

	* Date:         12/15/20
    * Developer:    Priya Srinivasan
    * Description:  Select TestMonitoring and TestAccessControl
 
    *****************************************************************
*/


CREATE PROCEDURE [eWeb].[GetTestSessions3]
	@AdministrationID int,
	@DistrictCode varchar(15)=null,
	@SchoolCode varchar(15)=null,
	@Test varchar(50)=null,
	@TestLevel varchar(20)=null,
	@ContentArea varchar(50)=null, 
	@currentUserEmail varchar(256)=null,
	@firstName varchar(100) = null,
	@lastName varchar(100) = null,
	@stateStudentID varchar(20) = null,
	@sessionName varchar(100) = null,
	@fromDate datetime = null,
	@toDate datetime = null
WITH RECOMPILE AS 

Declare @minFromDate datetime, @maxToDate datetime


If ((ISNULL(@FromDate, '') = '') or (ISNULL(@ToDate, '') = ''))
begin
	Select @minFromDate = '1753-01-01 00:00:00.000'
	Select @maxToDate = '9999-12-31 23:59:59.997'
end
Else
begin
	Select @minFromDate = @FromDate
	Select @maxToDate = @ToDate
end

select
	q.Name,
	q.TestSessionID,
	q.ContentArea,
	q.Test,
	q.Level,
	q.AssessmentText,
	IsOperationalTest=isnull(IsOperationalTest,1),
	Format,
	Status.Status,
	q.StartTime,
	q.EndTime,
	q.DistrictCode,
	D.SiteName as DistrictName,
	q.SchoolCode,
	S.SiteName as SchoolName, 
	q.Mode,
	q.StudentCountInCurrentUserGroup,
	q.TotalStudentCount,
	AllowEdits=isnull(ea.AllowEdits,0),
	ts.TestWindow,
	WindowDesription=ts.Description,
	ts.StartDate,
	ts.EndDate,
	cast(ts.IsDefault AS BIT) as IsDefault,
	cast(ts.AllowSessionDateEdits AS BIT) as AllowSessionDateEdits,
	q.ScoringOption,
	q.TestMonitoring,
	q.TestAccessControl
from (	select 
		s.AdministrationID,Name=max(s.Name),s.TestSessionID,ContentArea=max(isnull(t.ContentArea,t.Test)),Test=max(s.Test),Level=max(s.Level),
		AssessmentText=max(isnull(tl.Description,tl.Level)),TestWindow=max(s.TestWindow),
	StartTime=max(s.StartTime),EndTime=max(s.EndTime),DistrictCode=max(s.DistrictCode),SchoolCode=max(s.SchoolCode),
		Mode=max(s.Mode),StudentCountInCurrentUserGroup=count(distinct case when tt.Email is not null then gk.StudentID end),
	TotalStudentCount=count(distinct k.StudentID),
		MinStatus=min(tx.Status),MaxStatus=max(tx.Status),MinSubmitted=min(case when tx.Status='Completed' then 'Submitted' else tx.Status end),
	ScoringOption=MAX(s.ScoringOption), TestMonitoring = max(s.TestMonitoring), TestAccessControl=max(s.TestAccessControl)
	from Core.TestSession s
	inner join Scoring.Tests t on
	t.AdministrationID=s.AdministrationID and t.Test=s.Test
	inner join Scoring.TestLevels tl on tl.AdministrationID=s.AdministrationID and tl.Test=s.Test and tl.Level=s.Level
	inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and
	k.TestSessionID=s.TestSessionID
	inner join Document.TestTicketView tx on tx.AdministrationID=s.AdministrationID and tx.DocumentID=k.DocumentID
	inner join Core.Document doc on tx.AdministrationID=doc.AdministrationID and tx.DocumentID=doc.DocumentID
	inner join Core.Student stud on doc.AdministrationID=stud.AdministrationID and doc.StudentID=stud.StudentID
	left join StudentGroup.Links gk on gk.AdministrationID=s.AdministrationID and gk.StudentID=k.StudentID
	left join Teacher.StudentGroups tg on tg.AdministrationID=s.AdministrationID and tg.GroupID=gk.GroupID
	left join Core.Teacher tt on tt.AdministrationID=s.AdministrationID and tt.TeacherID=tg.TeacherID and tt.Email=@currentUserEmail
	where
		s.AdministrationID=@AdministrationID
		and (s.DistrictCode=@districtCode or @districtCode is null)
		--and (s.DistrictCode=@districtCode or isnull(@districtCode,'')='')
		and (s.SchoolCode=@schoolCode or @schoolCode is null)
		--and (s.SchoolCode=@schoolCode or isnull(@schoolCode,'')='')
		and (s.Test=@test or isnull(@test,'')='')
		and (s.Level=@testlevel or isnull(@testlevel,'')='') 
		and (stud.FirstName like @firstName + '%' or isnull(@firstName,'') = '')
		and (stud.LastName like @lastName + '%' or isnull(@lastName,'')='')
		and (stud.StateStudentID = @stateStudentID or isnull(@stateStudentID,'') = '')
		and (s.Name like '%' + @sessionName  + '%' or isnull(@sessionName,'') = '')
		and
	(t.ContentArea=@contentArea or isnull(@contentArea,'')='') 
		and not exists(select * from Config.Extensions x where x.AdministrationID=s.AdministrationID and x.Category='eWeb' and x.Name=s.Test+'.'+s.Level+'.Hide')
		and t.ContentArea not like '$%' and
	tl.Description not like '$%' 
	and (s.StartTime between @minFromDate and @maxToDate)     
	group by s.AdministrationID,s.TestSessionID) q
cross apply (select Status=case when MaxStatus in (MinStatus,MinSubmitted) and not (MinStatus='Completed' and MaxStatus='Not Started') then MaxStatus else 'In Progress' end) Status
cross apply (select Format=max(Format) from Scoring.TestForms f where f.AdministrationID=q.AdministrationID
	and f.Test=q.Test and f.Level=q.Level) Format
outer apply (select IsOperationalTest=cast(case when fieldtest.Value='Y' then 0 else 1 end as bit) from Config.Extensions fieldtest where fieldtest.AdministrationID=q.AdministrationID and
	fieldtest.Category='Assessment' and fieldtest.Name=q.Test+'.'+q.Level+'.FieldTest') IsOperationalTest
outer apply (select AllowEdits=CAST(ea.AllowEdits AS BIT) from Core.TestSession et inner join [Admin].AssessmentSchedule ea on ea.AdministrationID=et.AdministrationID and ea.TestWindow=et.TestWindow where et.AdministrationID=q.AdministrationID and
	et.TestSessionID=q.TestSessionID and ea.Test=q.Test and ea.Level=q.Level and ea.Mode=q.Mode) ea
left join [Admin].TestWindow ts on ts.AdministrationID=q.AdministrationID and ts.TestWindow=q.TestWindow
LEFT JOIN Core.Site D ON D.AdministrationID = @AdministrationID AND q.DistrictCode = D.SiteCode AND D.SiteType = 'District'
LEFT JOIN Core.Site S on D.AdministrationID = S.AdministrationID and S.SuperSiteCode = DistrictCode and s.SiteCode = SchoolCode
--left join [Site].TestWindows ss1 on ss1.AdministrationID=q.AdministrationID and ss1.DistrictCode=q.DistrictCode and ss1.SchoolCode=q.SchoolCode
--left join [Site].TestWindows ss2 on ss2.AdministrationID=q.AdministrationID and ss2.DistrictCode=q.DistrictCode
--	and ss2.SchoolCode is null
--left join [Admin].TestWindow ts on ts.AdministrationID=q.AdministrationID and (ts.TestWindow=coalesce(q.TestWindow,ss1.TestWindow,ss2.TestWindow) or (coalesce(ss1.TestWindow,ss2.TestWindow) is null and
--	ts.IsDefault=1))
;
GO
