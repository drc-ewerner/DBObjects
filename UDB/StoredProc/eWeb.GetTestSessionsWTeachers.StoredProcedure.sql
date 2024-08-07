USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestSessionsWTeachers]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*  *****************************************************************
    * Description:  This proc returns a list of Test sessionsw with Teachers
    *================================================================
    * Created:      ?
    * Developer:    ?
    *================================================================
    * Changes:
    *
    * Date:         7/14/14
    * Developer:    Dan Bellandi
    * Description:  Resolve Infra 137300 where the Test Session page was timing out.  
                    Just added an @administrationid filter to the ?with q? cte where clause.
		            In theory it shouldn?t be necessary because of the join to the temp table 
		            but the optimizer doesn?t ?know? that that join will restrict the whole query 
		            to a single administrationid so it chooses a (very much) less efficient plan.

	* Date:         10/03/17
    * Developer:    Alba Kampa
    * Description:  Added the @ScoringOption filter.

	* Date:         07/11/18
    * Developer:    Alba Kampa
    * Description:  Added the @OptionalItems field.

	* Date:         09/12/18
    * Developer:    Priya Srinivasan
    * Description:  Added the @FromDate, @ToDate, @minFromDate and @maxToDate

	* Date:         12/04/18
    * Developer:    Alba Kampa
    * Description:  Added Diagnostic Category and DC_Assessment
     
	* Date:         07/12/19
    * Developer:    Robert Lim
    * Description:  Updated DC_Assessment

	* Date:         12/01/20
    * Developer:    Priya Srinivasan
    * Description:  Added TestMonitoring and TestAccessControl in the select list
	
	* Date:         06/03/22
    * Developer:    Eric Werner
    * Description:  Added WITH RECOMPILE to proc definition.
	
	* Date:         02/08/23
    * Developer:    Julien Castilar
    * Description:  Added DC_Assessment2 for TerraNova
	*****************************************************************
*/
		CREATE PROCEDURE [eWeb].[GetTestSessionsWTeachers]
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
			   @teacherID int =0,
			   @ClassCode varchar(15) = null,
			   @ScoringOption varchar(100) = null,
			   @OptionalItems varchar(50) = null,
			   @FromDate datetime = null,
			   @ToDate datetime = null,
			   @maxResults INT
		WITH RECOMPILE
		as
		declare @tmpCoreTestSession TABLE (AdministrationID INT, TeacherID INT, TestSessionID INT PRIMARY KEY CLUSTERED (AdministrationID, TestSessionID))
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

		insert into @tmpCoreTestSession
		select top (@maxresults) s.AdministrationID,s.teacherid,s.TestSessionID
		from core.TestSession s
			   inner join Scoring.Tests t on t.AdministrationID=s.AdministrationID and t.Test=s.Test
			   inner join Scoring.TestLevels tl on tl.AdministrationID=s.AdministrationID and tl.Test=s.Test and tl.Level=s.Level
			   inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
			   inner join Core.Student stud on k.AdministrationID=stud.AdministrationID and k.StudentID=stud.StudentID 
		where
					  s.AdministrationID=@AdministrationID
					  and (s.DistrictCode=@districtCode or isnull(@districtCode,'')='')
					  and (s.SchoolCode=@schoolCode or isnull(@schoolCode,'')='')
					  and (s.Test=@test or isnull(@test,'')='')
					  and (s.Level=@testlevel or isnull(@testlevel,'')='') 
					  and (stud.FirstName like @firstName + '%' or isnull(@firstName,'') = '')
					  and (stud.LastName like @lastName + '%' or isnull(@lastName,'')='')
					  and (stud.StateStudentID = @stateStudentID or stud.DistrictStudentID = @stateStudentID or stud.SchoolStudentID = @stateStudentID or isnull(@stateStudentID,'') = '')
					  and (s.TeacherID = @teacherID or @teacherID=0)
					  and (s.Name like '%' + @sessionName  + '%' or isnull(@sessionName,'') = '')
					  and
			   (t.ContentArea=@contentArea or isnull(@contentArea,'')='') 
					  and not exists(select * from Config.Extensions x where x.AdministrationID=s.AdministrationID and x.Category='eWeb' and x.Name=s.Test+'.'+s.Level+'.Hide')
					  and t.ContentArea not like '$%' and
			   tl.Description not like '$%'      
					  and (s.ClassCode = @ClassCode or isnull(@ClassCode,'') = '')
							   and (s.ScoringOption = @ScoringOption or isnull(@ScoringOption,'') = '')
							   and (s.OptionalItems = @OptionalItems or isnull(@OptionalItems,'') = '')
							   and (s.StartTime between @minFromDate and @maxToDate)
			   group by s.AdministrationID,s.teacherid,s.TestSessionID;

		with DC_Assessment
		as (
		  select tsl.Test, tsl.Level, tsl.SubTest, tsl.SubLevel, tl.Description
		  from Scoring.Tests t
		  join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
		  join Scoring.TestSessionSubTestLevels tsl On tl.AdministrationID = tsl.AdministrationID and tl.Level = tsl.Level and tl.Test = tsl.Test
		  where t.AdministrationID = @AdministrationID
		),
		DC_Assessment2 AS (
		SELECT t.AdministrationID, tsl.Test, tsl.[Level], tsl.SubTest, tsl.SubLevel, tl.[Description], stl.TestSessionID
			FROM Scoring.Tests t
			JOIN Scoring.TestLevels tl ON tl.AdministrationID=t.AdministrationID AND tl.Test=t.Test
			JOIN Scoring.TestSessionSubTestLevels tsl ON tl.AdministrationID = tsl.AdministrationID AND tl.Level = tsl.SubLevel AND tl.Test = tsl.SubTest
			JOIN TestSession.SubTestLevels stl ON tl.AdministrationID = stl.AdministrationID AND tl.Level = stl.SubLevel AND tl.Test = stl.SubTest
			JOIN Config.Extensions x ON x.AdministrationID = @AdministrationID AND x.Category = 'eWeb' AND x.Name = 'TestTickets.UseAssessmentForSubTest' AND x.Value = 'Y' 
			WHERE t.AdministrationID = @AdministrationID
		),
		q 
		as (
			   select 
					  s.AdministrationID,s.TeacherID,Name=max(s.Name),s.TestSessionID,ContentArea=max(isnull(t.ContentArea,t.Test)),Test=max(isnull(dca.Test, s.Test)),Level=max(isnull(dca.Level, tl.Level)),SubTest=max(isnull(dca.SubTest, '')),SubLevel=max(isnull(dca.SubLevel, '')),
					  AssessmentText=max(isnull(dca2.Description, isnull(dca.Description, isnull(tl.Description,tl.Level)))),
					  DiagnosticCategoryText=case when max(dca.Description) is null then '' else max(isnull(tl.Description, tl.Level)) end,
					  TestWindow=max(s.TestWindow),
			   StartTime=max(s.StartTime),EndTime=max(s.EndTime),DistrictCode=max(s.DistrictCode),SchoolCode=max(s.SchoolCode),
					  Mode=max(s.Mode),StudentCountInCurrentUserGroup=count(distinct case when tt.Email is not null then gk.StudentID end),
			   TotalStudentCount=count(distinct k.StudentID),
					  MinStatus=min(tx.Status),MaxStatus=max(tx.Status),MinSubmitted=min(case when tx.Status='Completed' then 'Submitted' else tx.Status end),
					  ClassCode=MAX(s.ClassCode),
				  ScoringOption=MAX(s.ScoringOption),
				  OptionalItems=MAX(ISNULL(s.OptionalItems, '')),
				  TestMonitoring=MAX(s.TestMonitoring),
				  TestAccessControl=MAX(s.TestAccessControl)
			   from Core.TestSession s
			   inner join @tmpCoreTestSession s2 on s.AdministrationID = s2.AdministrationID and isnull(s.TeacherID,'') = isnull(s2.TeacherID,'') and s.TestSessionID = s2.TestSessionID
			   inner join Scoring.Tests t on t.AdministrationID=s.AdministrationID and t.Test=s.Test
			   inner join Scoring.TestLevels tl on tl.AdministrationID=s.AdministrationID and tl.Test=s.Test and tl.Level=s.Level
				  left join DC_Assessment dca on tl.Test = dca.SubTest and tl.Level = dca.SubLevel
			   inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
			   inner join Document.TestTicketView tx on tx.AdministrationID=s.AdministrationID and tx.DocumentID=k.DocumentID
			   inner join Core.Student stud on k.AdministrationID=stud.AdministrationID and k.StudentID=stud.StudentID
			   left join StudentGroup.Links gk on gk.AdministrationID=s.AdministrationID and gk.StudentID=k.StudentID
			   left join Teacher.StudentGroups tg on tg.AdministrationID=s.AdministrationID and tg.GroupID=gk.GroupID
			   left join Core.Teacher tt on tt.AdministrationID=s.AdministrationID and tt.TeacherID=tg.TeacherID and tt.Email=@currentUserEmail
			   left join DC_Assessment2 dca2 ON s.AdministrationID = dca2.AdministrationID AND s.TestSessionID = dca2.TestSessionID
					  where s.administrationid=@administrationid
				  group by s.AdministrationID,s.teacherid,s.TestSessionID
		)
		select 
			   q.Name,
			   isnull(q.teacherid,0) TeacherID,
			   q.TestSessionID,
			   q.ContentArea,
			   q.Test,
			   q.Level,
			   q.SubTest,
			   q.SubLevel,
			   q.AssessmentText,
			   q.DiagnosticCategoryText,
			   IsOperationalTest=isnull(IsOperationalTest,1),
			   Format,
			   Status,
			   q.StartTime,
			   q.EndTime,
			   q.DistrictCode,
			   q.SchoolCode, 
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
			   q.ClassCode,
			   q.ScoringOption,
			   q.OptionalItems,
			   q.TestMonitoring,
			   q.TestAccessControl
		from q
		cross apply (select Status=case when MaxStatus in (MinStatus,MinSubmitted) and not (MinStatus='Completed' and MaxStatus='Not Started') then MaxStatus else 'In Progress' end) Status
		cross apply (select Format=max(Format) from Scoring.TestForms f where f.AdministrationID=q.AdministrationID
			   and f.Test=q.Test and f.Level=q.Level) Format
		outer apply (select IsOperationalTest=cast(case when fieldtest.Value='Y' then 0 else 1 end as bit) from Config.Extensions fieldtest where fieldtest.AdministrationID=q.AdministrationID and
			   fieldtest.Category='Assessment' and fieldtest.Name=q.Test+'.'+q.Level+'.FieldTest') IsOperationalTest
		outer apply (select AllowEdits=CAST(ea.AllowEdits AS BIT) from Core.TestSession et inner join [Admin].AssessmentSchedule ea on ea.AdministrationID=et.AdministrationID and ea.TestWindow=et.TestWindow where et.AdministrationID=q.AdministrationID and
			   et.TestSessionID=q.TestSessionID and ea.Test=q.Test and ea.Level=q.Level and ea.Mode=q.Mode) ea
		left join [Admin].TestWindow ts on ts.AdministrationID=q.AdministrationID and ts.TestWindow=q.TestWindow
		--left join [Site].TestWindows ss1 on ss1.AdministrationID=q.AdministrationID and ss1.DistrictCode=q.DistrictCode and ss1.SchoolCode=q.SchoolCode
		--left join [Site].TestWindows ss2 on ss2.AdministrationID=q.AdministrationID and ss2.DistrictCode=q.DistrictCode
		--     and ss2.SchoolCode is null
		--left join [Admin].TestWindow ts on ts.AdministrationID=q.AdministrationID and (ts.TestWindow=coalesce(q.TestWindow,ss1.TestWindow,ss2.TestWindow) or (coalesce(ss1.TestWindow,ss2.TestWindow) is null and
		--     ts.IsDefault=1))
GO
