USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestSessionsWStudentDetails]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetTestSessionsWStudentDetails]
	@AdministrationID int,
	@DistrictCode varchar(15),
	@SchoolCode varchar(15),
	@Test varchar(50)=null,
	@TestLevel varchar(20)=null,
	@ContentArea varchar(50)=null, 
	@currentUserEmail varchar(256)=null,
	@firstName varchar(100) = null,
	@lastName varchar(100) = null,
	@stateStudentID varchar(20) = null,
	@sessionName varchar(100) = null,
	@teacherID int =0,
	@ClassCode varchar(15) = null
WITH RECOMPILE
AS

BEGIN
	SET NOCOUNT ON; set transaction isolation level read uncommitted;

DECLARE @Form As VARCHAR(20)

SELECT @Form = eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','TestSessions.Export.Form.FieldName', '');

with DC_Assessment
as (
  select tsl.Test, tsl.Level, tsl.SubTest, tsl.SubLevel, tl.Description
  from Scoring.Tests t
  join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
  join Scoring.TestSessionSubTestLevels tsl On tl.AdministrationID = tsl.AdministrationID and tl.Level = tsl.Level and tl.Test = tsl.Test
  where t.AdministrationID = @AdministrationID
)
    select DISTINCT
		s.AdministrationID,
		s.DistrictCode,
		dist.SiteName DistrictName,
		s.SchoolCode,
		sch.SiteName SchoolName,
		s.Name SessioName,
		ContentArea=(isnull(t.ContentArea,t.Test)),
		AssessmentText=(isnull(dca.Description, isnull(tl.Description,tl.Level))),
		DiagnosticCategoryText=case when dca.Description is null then '' else isnull(tl.Description, tl.Level) end,
		CASE WHEN LTRIM(RTRIM(ISNULL(f.FormSessionName, ''))) <> '' THEN LTRIM(RTRIM(ISNULL(f.FormSessionName, ''))) 
			 WHEN fp.PartName IS NULL THEN '' 
			 ELSE 'Module ' + fp.PartName 
		END AS PartName,
		s.StartTime as SessionStart, 
		s.EndTime as SessionEnd,
		stud.FirstName, 
		stud.LastName,
		stud.StateStudentID,
		stud.Grade,
		tx.UserName, 
		tx.[Password], 
		tx.[status],
		TicketStart=tx.StartTime,
		TicketEnd=case tx.Status when 'In Progress' then null else tx.EndTime end,
		LocalStartTime=tx.[LocalStartTime], 
		LocalEndTime=case tx.Status when 'In Progress' then null else tx.LocalEndTime end, 
		DATEDIFF(hh,tx.[StartTime],tx.[LocalStartTime]) AS LocalOffset,
		Accommodations = COALESCE(LEFT(Accommodations, LEN(Accommodations) - 1), ''),
		TestingCodes = COALESCE(LEFT(TestingCodes, LEN(TestingCodes) - 1), ''),
		CASE WHEN @Form = 'FormName'
		THEN ISNULL(f.FormName, '')
		WHEN @Form = 'Form'
			THEN ISNULL(f.Form, '')
			WHEN @Form = 'VisualIndicator'
				THEN ISNULL(f.VisualIndicator, '')
				ELSE ''
		END As Form,
		s.Mode,
		tx.Timezone,
		ReportedSchoolSIDN = COALESCE(ReportedSchoolSIDN, '')
	from Core.TestSession s 
		inner join Scoring.Tests t on t.AdministrationID=s.AdministrationID and t.Test=s.Test
		inner join Scoring.TestLevels tl on tl.AdministrationID=s.AdministrationID and tl.Test=s.Test and tl.Level=s.Level
		left join DC_Assessment dca on tl.Test = dca.SubTest and tl.Level = dca.SubLevel
		inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and       k.TestSessionID=s.TestSessionID
		inner join Document.TestTicketView tx on tx.AdministrationID=s.AdministrationID and tx.DocumentID=k.DocumentID
		inner join Core.Student stud on k.AdministrationID=stud.AdministrationID and k.StudentID=stud.StudentID
		left join StudentGroup.Links gk on gk.AdministrationID=s.AdministrationID and gk.StudentID=k.StudentID
		left join Teacher.StudentGroups tg on tg.AdministrationID=s.AdministrationID and tg.GroupID=gk.GroupID
		left join Core.Teacher tt on tt.AdministrationID=s.AdministrationID and tt.TeacherID=tg.TeacherID and tt.Email=@currentUserEmail
		inner join core.Site sch on stud.AdministrationId = sch.AdministrationID and stud.SchoolCode = sch.SiteCode and stud.Districtcode  = sch.SuperSiteCode
		inner join core.Site dist on stud.AdministrationID = dist.AdministrationId and stud.DistrictCode = dist.Sitecode and dist.SuperSitecode = 'DEPTOFED'
		left join Scoring.TestForms f on tx.AdministrationID = f.AdministrationID and tx.Test = f.Test and tx.Level = f.Level and tx.Form = f.Form
		left join Scoring.TestFormParts fp on tx.AdministrationID = fp.AdministrationID and tx.Test = fp.Test and tx.Level = fp.Level and tx.Form = fp.FormPart
		OUTER APPLY (
		   SELECT 
				  LEFT([sx].[Name], CHARINDEX('.', [sx].[Name]) - 1) + ': ' + [sx].[DisplayName] + '; '
		   FROM
				  [XRef].[StudentExtensionNames] [sx]
				  INNER JOIN [Student].[Extensions] [x] ON
						 [sx].[category] = [x].[category] AND
						 [sx].[name] = [x].[name] AND
						 [sx].[AdministrationID] = [x].[AdministrationID]
				  WHERE
						 [x].[AdministrationID] = tx.[AdministrationID] AND
						 [x].[StudentID] = stud.[StudentID] AND
						 [x].[Category] = t.[ContentArea] AND
						 [x].[Value] = 'Y'
				  ORDER BY [sx].[Name], [sx].[DisplayName]
		   FOR XML PATH('')) [sx](Accommodations)
		OUTER APPLY (
		   SELECT 
				  REPLACE([XSE].DisplayName,'<br/>','') + ': ' + [x].[Value] + '; '
		   FROM
				  [Student].[Extensions] [x], [XRef].[StudentExtensionNames] [XSE]
				  WHERE
						 [x].[AdministrationID] = tx.[AdministrationID] AND
						 [x].[StudentID] = stud.[StudentID] AND
						 [x].[Category] = 'TestingCodes' AND
						 [x].[Name] LIKE tl.Level + '_' + tl.Test + '_%' AND
						 [XSE].Name LIKE '%' + REPLACE([x].[Name],  tl.Level + '_' + tl.Test + '_', '') + '%' AND
						 [x].[AdministrationID] = [XSE].AdministrationID AND
						 [XSE].[Category] = 'TestingCodes'
				  ORDER BY [x].[Name]
		   FOR XML PATH('')) [x](TestingCodes)
		OUTER APPLY (
		   SELECT
				  [y].[Value]
				  --REPLACE([y].[Name],  tl.Level + '_' + tl.Test + '_', '') + ': ' + [y].[Value] + '; '
		   FROM
				  [Student].[Extensions] [y]
				  WHERE
						 [y].[AdministrationID] = tx.[AdministrationID] AND
						 [y].[StudentID] = stud.[StudentID] AND
						 (
						   ([y].[Category] = 'Demographic' AND 
						   [y].[Name] = 'ReportedSchoolSIDN') 
						 )
		   --  ORDER BY [y].[Name]
		   --FOR XML PATH('')
		   ) [y](ReportedSchoolSIDN)	   
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
		and (t.ContentArea=@contentArea or isnull(@contentArea,'')='') 
		and not exists(select * from Config.Extensions x where x.AdministrationID=s.AdministrationID and x.Category='eWeb' and x.Name=s.Test+'.'+s.Level+'.Hide')
		and t.ContentArea not like '$%' and tl.Description not like '$%'     
		and (s.ClassCode = @ClassCode or isnull(@ClassCode,'') = '')
	order by SessioName, ContentArea, AssessmentText, stud.LastName, stud.firstName
END
GO
