USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAssessmentsByContentArea]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [eWeb].[GetAssessmentsByContentArea] (@AdministrationID int,@ContentArea varchar(50))
as
/* 08/18/2010 - Version 1.0 */
--2/14/2011, changed to sort alpha on content area and description

select 
	t.Test,tl.Level,
	AssessmentText=isnull(tl.Description,tl.Level)
from Scoring.Tests t
join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
left join Config.Extensions ext on ext.AdministrationID=tl.AdministrationID and ext.Category='eWeb' and ext.Name=tl.Test + '.' + tl.Level + '.Hide'
where t.AdministrationID=@AdministrationID and t.ContentArea=@ContentArea and tl.Description not like '$%'
and isnull(ext.Value, 'N') = 'N'
order by t.ContentArea,AssessmentText
GO
