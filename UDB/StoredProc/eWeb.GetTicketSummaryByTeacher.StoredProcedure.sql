USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTicketSummaryByTeacher]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [eWeb].[GetTicketSummaryByTeacher] 
	@AdministrationID int,
	@TeacherID int,
	@DistrictCode varchar(15) = '',
	@SchoolCode varchar(15) = ''
as
begin
	/* 08/31/2010 - Version 1.0.1 */
with DC_Assessment
as (
  select tsl.Test, tsl.Level, tsl.SubTest, tsl.SubLevel, tl.Description
  from Scoring.Tests t
  join Scoring.TestLevels tl on tl.AdministrationID=t.AdministrationID and tl.Test=t.Test
  join Scoring.TestSessionSubTestLevels tsl On tl.AdministrationID = tsl.AdministrationID and tl.Level = tsl.Level and tl.Test = tsl.Test
  where t.AdministrationID = @AdministrationID
)
	SELECT     tes.ContentArea, isnull(max(dca.Description), isnull(tl.Description,tl.Level)) Test, case when max(dca.Description) is null then '' else isnull(tl.Description, tl.Level) end SubTest,
	 NotStarted = ISNULL(count( distinct CASE WHEN tck.Status= 'Not Started' THEN lnk.StudentID ELSE NULL END), 0),   
	 InProgess = ISNULL(count( distinct CASE WHEN tck.Status= 'In Progress' THEN lnk.StudentID ELSE NULL END), 0),
	 Submitted = ISNULL(count( distinct CASE WHEN tck.Status= 'Submitted' THEN lnk.StudentID ELSE NULL END), 0),  
	 Finish = ISNULL(count( distinct CASE WHEN tck.Status= 'Completed' THEN lnk.StudentID ELSE NULL END), 0) 	
	FROM         Core.TestSession AS ses INNER JOIN
						  TestSession.Links AS lnk ON ses.AdministrationID = lnk.AdministrationID AND ses.TestSessionID = lnk.TestSessionID INNER JOIN
						  Scoring.Tests AS tes ON ses.AdministrationID = tes.AdministrationID and ses.Test = tes.test INNER JOIN
						  [Document].TestTicketView AS tck ON lnk.AdministrationID = tck.AdministrationID AND lnk.DocumentID = tck.DocumentID inner join
						  Scoring.TestLevels tl on tck.AdministrationID = tl.AdministrationID and tck.Test = tl.Test and tck.Level = tl.Level left join
						  DC_Assessment dca on tl.Test = dca.SubTest and tl.Level = dca.SubLevel left join 
						  Config.Extensions ext on ext.AdministrationID=tl.AdministrationID and ext.Category='eWeb' and ext.Name=tl.Test + '.' + tl.Level + '.Hide' left join 
						  StudentGroup.Links slnk on slnk.AdministrationID=ses.AdministrationID and slnk.StudentID=lnk.StudentID inner join 
						  Teacher.StudentGroups tg on tg.AdministrationID=ses.AdministrationID and tg.GroupID=slnk.GroupID and tg.TeacherId=ses.TeacherId
	where ses.AdministrationID = @AdministrationID and 
	(ses.DistrictCode=@districtCode or @districtCode = '') and
	(ses.SchoolCode = @schoolCode or @schoolCode = '') and charindex('$',tes.ContentArea) =0 and  charindex('$',isnull(tl.Description,tl.Level)) =0 and
	isnull(ext.Value, 'N') = 'N' and ses.Mode in ('Online', 'Proctored')
	and ses.TeacherId = @TeacherID
	GROUP BY tes.ContentArea, isnull(tl.Description,tl.Level) 
	
end
GO
