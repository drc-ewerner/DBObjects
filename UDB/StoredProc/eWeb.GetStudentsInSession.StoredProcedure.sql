USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentsInSession]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [eWeb].[GetStudentsInSession] (@AdministrationID int,@SessionID int)
as 
select distinct s.StudentID,
				s.StateStudentID,
				s.DistrictStudentID,
				s.SchoolStudentID,
				s.LastName,
				s.FirstName,
				AssessmentSessionCount = (
					select count(distinct ts.TestSessionID) 
					from Core.TestSession ts
					inner join TestSession.Links sl on ts.AdministrationID=sl.AdministrationID and ts.TestSessionID=sl.TestSessionID 
					where
					ts.AdministrationID = g.AdministrationID and
					ts.Test=g.Test and
					ts.Level = g.Level and
					sl.StudentID = s.StudentID)
from Core.TestSession g
inner join TestSession.Links k on k.AdministrationID=g.AdministrationID and k.TestSessionID=g.TestSessionID
inner join Core.Student s on s.AdministrationID=g.AdministrationID and s.StudentID=k.StudentID
where g.AdministrationID=@AdministrationID and g.TestSessionID=@SessionID
GO
