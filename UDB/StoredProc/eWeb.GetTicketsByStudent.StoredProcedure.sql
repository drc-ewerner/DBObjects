USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTicketsByStudent]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetTicketsByStudent] 
@AdministrationID int,
@StudentID int
AS
BEGIN

DECLARE @isMulti BIT, @isMultiSelect BIT

SELECT @isMulti = CASE eWeb.GetConfigExtensionValue(@AdministrationID, 'INSIGHT', 'ContinuousMultiModule', 'N')
					WHEN 'Y' THEN 1
					ELSE 0
				  END

SELECT @isMultiSelect = CASE eWeb.GetConfigExtensionValue(@AdministrationID, 'eWeb', 'ConfigUI.UseMultiSelectSessionModal', 'N')
					WHEN 'Y' THEN 1
					ELSE 0
				  END
;
with 
 DC_Assessment
as (
	  select distinct tsl.Test, tsl.Level, tsl.SubTest, tsl.SubLevel, tl.Description
	  from Scoring.Tests t
	  join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
	  join Scoring.TestSessionSubTestLevels tsl On tl.AdministrationID = tsl.AdministrationID and tl.Level = tsl.Level and tl.Test = tsl.Test
	)
select distinct
	t.AdministrationID,
	t.DocumentID,
	t.PartName,
	ContentArea=isnull(st.ContentArea,st.Test),
	AssessmentText= CASE 
						WHEN @isMulti = 1 THEN stf.FormSessionName
						WHEN @isMultiSelect = 1 THEN stf.FormSessionName
						when isnull(t.PartName,'')='' then isnull(dca.Description, isnull(tl.Description,tl.Level)) 
                        WHEN ISNULL(stf.FormSessionName,'') = '' 
                            THEN 'Module ' + t.PartName 
                        ELSE stf.FormSessionName 
                END,
    DiagnosticCategoryText=case when dca.Description is null then '' else isnull(tl.Description, tl.Level) end,
	ts.TestSessionID, 
	ts.DistrictCode, ts.SchoolCode, 
	SessionName = ts.Name, 
	TicketStatus= case when isnull(ts.Mode,'') = 'PAPER' then ts.mode else t.Status end,
	TicketStartTime=t.StartTime,
	TicketEndTime=t.EndTime,
	t.[LocalStartTime], 
	t.[LocalEndTime], 
	DATEDIFF(hh,t.[StartTime],t.[LocalStartTime]) AS LocalOffset,
	TimeUnlocked=t.UnlockTime,
	ts.Mode,
	Format,
	ReportingCode=isnull(t.ReportingCode, ''),
	t.NotTestedCode,
	t.[Level],
	t.Timezone
from Core.TestSession ts 
inner join Scoring.Tests st on st.AdministrationID=ts.AdministrationID and st.Test=ts.Test
inner join Scoring.TestLevels tl on tl.AdministrationID=ts.AdministrationID and tl.Test=ts.Test and tl.Level=ts.Level
left join DC_Assessment dca on tl.Test = dca.subTest and tl.Level = dca.subLevel
inner join TestSession.Links k on k.AdministrationID=ts.AdministrationID and k.TestSessionID=ts.TestSessionID
inner join Document.TestTicketView t on t.AdministrationID=k.AdministrationID and t.DocumentID=k.DocumentID 
left join [Scoring].[TestForms] [stf] ON
              t.[AdministrationID] = [stf].[AdministrationID] AND
              t.[Test] = [stf].[Test] AND
              t.[Level] = [stf].[Level] AND
              t.[Form] = [stf].[Form]
inner join Core.Student s on s.AdministrationID=ts.AdministrationID and s.StudentID=k.StudentID
where ts.AdministrationID=@AdministrationID and k.StudentID=@StudentID
order By ts.TestSessionID 


END
GO
