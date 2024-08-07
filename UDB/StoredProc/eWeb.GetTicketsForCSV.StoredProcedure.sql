USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTicketsForCSV]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetTicketsForCSV] 
@AdministrationID INT,
@TestSessionID INT
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

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
SELECT 
	dist.SiteCode DistrictCode,
	dist.SiteName DistrictName, 
	sch.SiteCode SchoolCode,
	sch.SiteName SchoolName,
	testSession.Name SessioName,
	tes.ContentArea ,
	tl.Level,
	AssessmentText=(isnull(dca.Description, isnull(tl.Description,tl.Level))),
	DiagnosticCategoryText=case when dca.Description is null then '' else isnull(tl.Description, tl.Level) end,
	student.FirstName, 
	student.LastName,
	student.StateStudentID,
	CASE WHEN LTRIM(RTRIM(ISNULL(f.FormSessionName, ''))) <> '' THEN LTRIM(RTRIM(ISNULL(f.FormSessionName, ''))) 
	     WHEN fp.PartName IS NULL THEN '' 
		 ELSE 'Module ' + fp.PartName 
	END AS PartName,
	ticket.Test,
	student.grade,
	ticket.UserName,
	ticket.Password,
	ticket.Status,
	TicketStart=ticket.StartTime,
	TicketEnd=ticket.EndTime,
	ticket.[LocalStartTime], 
	ticket.[LocalEndTime], 
	DATEDIFF(hh,ticket.[StartTime],ticket.[LocalStartTime]) AS LocalOffset,
	testSession.StartTime as SessionStart, 
	testSession.EndTime as SessionEnd,
	NonAssessedCode = na.Value,
	NonPublicEnrolled = np.Value,
	CourtAgencyPlaced = se.Value,
	Accommodations = COALESCE(LEFT(Accommodations, LEN(Accommodations) - 1), ''),
	TestingCodes = COALESCE(LEFT(TestingCodes, LEN(TestingCodes) - 1), ''),
	ReportedSchoolSIDN = COALESCE(ReportedSchoolSIDN, ''),
	CASE WHEN @Form = 'FormName'
		THEN ISNULL(f.FormName, '')
		WHEN @Form = 'Form'
			THEN ISNULL(f.Form, '')
			WHEN @Form = 'VisualIndicator'
				THEN ISNULL(f.VisualIndicator, '')
				ELSE ''
	END As Form,
	ticket.Timezone
FROM Document.TestTicketView ticket
	inner join TestSession.Links sessionLink on sessionLink.DocumentID = ticket.DocumentID and sessionLink.AdministrationId = ticket.AdministrationId
	inner join Core.TestSession testSession on testSession.TestSessionID = sessionLink.TestSessionID and testSession.AdministrationId = sessionLink.AdministrationId
	inner join Scoring.Tests tes on testSession.AdministrationID = tes.AdministrationID and testSession.Test=tes.Test
	inner join Scoring.TestLevels tl on tl.AdministrationID=testSession.AdministrationID and tl.Test=testSession.Test and tl.[level] = testSession.[Level]
	left join DC_Assessment dca on tl.Test = dca.SubTest and tl.Level = dca.SubLevel
	left join Scoring.TestForms f on ticket.AdministrationID = f.AdministrationID and ticket.Test = f.Test and ticket.Level = f.Level and ticket.Form = f.Form
	left join Scoring.TestFormParts fp on ticket.AdministrationID = fp.AdministrationID and ticket.Test = fp.Test and ticket.Level = fp.Level and ticket.Form = fp.FormPart
	inner join Core.Student student on student.StudentID = sessionLink.StudentID and student.AdministrationID = sessionLink.AdministrationId
	inner join core.Site sch on student.AdministrationId = sch.AdministrationID and student.SchoolCode = sch.SiteCode and student.Districtcode  = sch.SuperSiteCode
	inner join core.Site dist on student.AdministrationID = dist.AdministrationId and student.DistrictCode = dist.Sitecode and dist.SuperSitecode = 'DEPTOFED'
	left join Document.Extensions na on na.AdministrationID=ticket.AdministrationID and na.DocumentID=ticket.DocumentID and na.[Name] = 'NonAssessedCd'
	left join Document.Extensions np on np.AdministrationID=ticket.AdministrationID and np.DocumentID=ticket.DocumentID and np.[Name] = 'NonPublicEnrolled'
	left join Student.Extensions se on se.AdministrationID = student.AdministrationID and se.StudentID = student.StudentID and se.Category = 'Residence' and se.[Name] = 'CourtAgencyPlaced'
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
                     [x].[AdministrationID] = [ticket].[AdministrationID] AND
                     [x].[StudentID] = [student].[StudentID] AND
                     [x].[Category] = [tes].[ContentArea] AND
                     [x].[Value] = 'Y'
              ORDER BY [sx].[Name], [sx].[DisplayName]
       FOR XML PATH('')) [sx](Accommodations)
    OUTER APPLY (
       SELECT
              REPLACE([x].[Name],  tl.Level + '_' + tl.Test + '_', '') + ': ' + [x].[Value] + '; '
       FROM
              [Student].[Extensions] [x]
              WHERE
                     [x].[AdministrationID] = [ticket].[AdministrationID] AND
                     [x].[StudentID] = [student].[StudentID] AND
                     (
					   ([x].[Category] = 'TestingCodes' AND --'Demographic' AND --'TestingCodes' AND
					   [x].[Name] LIKE tl.Level + '_' + tl.Test + '_%' 
					   AND [x].[Name] NOT LIKE '%ReportedSchoolSIDN'
					   ) 
					 )
                     --[x].[Value] = 'Y'
              ORDER BY [x].[Name]
       FOR XML PATH('')) [x](TestingCodes)
	OUTER APPLY (
       SELECT
              [y].[Value]
			  --REPLACE([y].[Name],  tl.Level + '_' + tl.Test + '_', '') + ': ' + [y].[Value] + '; '
       FROM
              [Student].[Extensions] [y]
              WHERE
                     [y].[AdministrationID] = [ticket].[AdministrationID] AND
                     [y].[StudentID] = [student].[StudentID] AND
                     (
					   ([y].[Category] = 'Demographic' AND 
					   [y].[Name] = 'ReportedSchoolSIDN') 
					 )
       --       ORDER BY [y].[Name]
       --FOR XML PATH('')
	   ) [y](ReportedSchoolSIDN)

WHERE ticket.AdministrationID = @AdministrationID and testSession.TestSessionID = @TestSessionID 
ORDER BY Test, LastName, FirstName, Status DESC
END
GO
