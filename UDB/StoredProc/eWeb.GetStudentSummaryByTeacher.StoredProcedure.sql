USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentSummaryByTeacher]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetStudentSummaryByTeacher]
	   @AdministrationID int, 
	   @TeacherID int,
       @DistrictCode varchar(15)=null,
       @SchoolCode varchar(15)=null
As

Set nocount on

Set transaction isolation level read uncommitted 

	   Select s.AdministrationID, 
       s.Name as SessionName, 
       s.TestSessionID, 
       cs1.sitename as SchoolName, 
       cs2.sitename as DistrictName,
       max(isnull(tl.Description,tl.Level)) as Assessment,
	   NotStarted = ISNULL(count( distinct CASE WHEN x.Status= 'Not Started' THEN k.StudentID ELSE NULL END), 0),   
	   InProgess = ISNULL(count( distinct CASE WHEN x.Status= 'In Progress' THEN k.StudentID ELSE NULL END), 0),   
	   Finish = ISNULL(count( distinct CASE WHEN x.Status= 'Completed' THEN k.StudentID ELSE NULL END), 0)
       from Core.TestSession s
       inner join Scoring.Tests AS tes ON s.AdministrationID = tes.AdministrationID and s.Test = tes.test
       inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
       inner join Document.TestTicketView x on x.AdministrationID=s.AdministrationID and x.DocumentID=k.DocumentID
       inner join Scoring.TestLevels tl on x.AdministrationID = tl.AdministrationID and x.Test = tl.Test and x.Level = tl.level
       left join Config.Extensions ext on ext.AdministrationID=tl.AdministrationID and ext.Category='eWeb' and ext.Name=tl.Test + '.' + tl.Level + '.Hide'
       inner join Core.Site cs1 on cs1.AdministrationID = s.AdministrationID and cs1.SiteType = 'School' and cs1.SiteCode = s.SchoolCode and cs1.SuperSiteCode = s.DistrictCode 
       inner join Core.Site cs2 on cs2.AdministrationID = s.AdministrationID and cs2.SiteType = 'District' and cs2.SiteCode = s.DistrictCode 
	   inner join StudentGroup.Links gk on gk.AdministrationID=s.AdministrationID and gk.StudentID=k.StudentID
       inner join Teacher.StudentGroups tg on tg.AdministrationID=s.AdministrationID and tg.GroupID=gk.GroupID and tg.TeacherId=s.TeacherId 
       where s.AdministrationID = @AdministrationID
              and (DistrictCode = @DistrictCode or @DistrictCode = '')
              and (SchoolCode =  @SchoolCode or @SchoolCode = '') 
              and charindex('$',tes.ContentArea) =0  and charindex('$',isnull(tl.Description,tl.Level)) = 0
              and isnull(ext.Value, 'N') = 'N' and s.Mode in ('Online', 'Proctored')
			  and s.TeacherID = @TeacherID 
       group by s.AdministrationID, s.Name, cs1.sitename, cs2.sitename,  s.TestSessionID
GO
