USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAssessmentsByGrade]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [eWeb].[GetAssessmentsByGrade]
@AdministrationID INT,
@Grade varchar(2)
AS
with f as (

select AdministrationID, Test, Level, Format = max(Format)  from Scoring.TestForms
where AdministrationID = @AdministrationID
group by AdministrationID, Test, Level
)
select 
       t.ContentArea,
       t.Test,
       tl.Level,
       AssessmentText=isnull(tl.[Description],tl.Level),
       IsBasicTelemetry = case when telemetry.AdministrationID = @AdministrationID then cast( 1 as BIT) else cast(0 as BIT) end,
       IsOperationalTest = case when optest.[Value] = 'Y' then cast( 0 as bit) else cast( 1 as bit) end,
       IsObsoleted = (
              select case when count(*)>0 then cast(0 as bit) else cast(1 as bit) end
              from scoring.testforms
              where administrationid = @AdministrationID and Test=t.Test and Level=tl.Level
              and coalesce([status],'Active') not in ('Obsolete', 'Obsolete-Pending')
       ),
       f.Format 
from Scoring.Tests t
inner join Scoring.ContentAreas ca on t.AdministrationID = ca.AdministrationID and t.ContentArea = ca.ContentArea
inner join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
left join Config.Extensions ext on ext.AdministrationID=tl.AdministrationID and ext.Category='eWeb' and ext.Name=tl.Test + '.' + tl.Level + '.Hide'
left join Config.Extensions ext2 on ext2.AdministrationID=tl.AdministrationID and ext2.Category='eWeb' and ext2.Name=t.ContentArea + '.Hide'
left join Config.Extensions telemetry on telemetry.AdministrationID=tl.AdministrationID and telemetry.Category = 'Telemetry' and telemetry.Name = tl.Test +'.' + tl.Level and telemetry.Value = '<Basic/>'
left join Config.Extensions optest on optest.AdministrationID=tl.AdministrationID and optest.Category = 'Assessment' and optest.Name = tl.Test +'.' + tl.Level + '.FieldTest'
left join f on f.AdministrationID = t.AdministrationID And f.Test = t.Test and f.Level = tl.Level
join Scoring.TestLevelGrades tlg on tl.Level = tlg.Level and t.test = tlg.test AND t.AdministrationID = tlg.AdministrationID


where t.AdministrationID=@AdministrationID 
and ca.IsForTestSessions = 1
and (t.ContentArea not like '$%' ) and (tl.Description not like '$%')
--and (isnull(ext.Value, 'N') = 'N' or @ShowHidden = 1) and (isnull(ext2.Value, 'N') = 'N' or @ShowHidden = 1)
and tlg.Grade = @Grade
order by t.ContentArea,AssessmentText
GO
