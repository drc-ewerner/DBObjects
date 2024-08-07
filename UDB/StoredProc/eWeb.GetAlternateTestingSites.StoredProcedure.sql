USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAlternateTestingSites]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[GetAlternateTestingSites]

@AdministrationID int,
@DistrictCode varchar(15),
@SchoolCode varchar(15),
@currentUserEmail VARCHAR (256)=null

As

Begin

select s.AdministrationID,s.TestSessionID,
	Status = case 
				when count(x.DocumentID) = sum(case when x.Status = 'Not Started' then 1 else 0 end) then 'Not Started'
				when count(x.DocumentID) = sum(case when x.Status = 'Submitted' then 1 else 0 end) then 'Submitted'
				when count(x.DocumentID) = sum(case when x.Status = 'Completed' then 1 else 0 end) then 'Completed'
					when count(x.DocumentID)  =sum(case when x.Status = 'Submitted' or x.Status = 'Completed' then 1 else 0 end)   then 'Submitted'
				else 'In Progress' 
			end
	into #q
	from Core.TestSession s
	inner join Scoring.Tests AS tes ON s.AdministrationID = tes.AdministrationID and s.Test = tes.test
	inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
	inner join Document.TestTicketView x on x.AdministrationID=s.AdministrationID and x.DocumentID=k.DocumentID
	where s.AdministrationID=@AdministrationID
	and (SchoolCode != @SchoolCode ) 
	group by s.AdministrationID,s.TestSessionID


	select lnk.AdministrationID, lnk.StudentID, teach.TeacherID
	into #UsersStudents
	from StudentGroup.Links lnk 
	inner join Teacher.StudentGroups grp ON grp.AdministrationID=lnk.AdministrationID and grp.GroupID=lnk.GroupID
	inner join Core.Teacher teach ON teach.AdministrationID=lnk.AdministrationID and teach.TeacherID=grp.TeacherID
		and teach.Email = @currentUserEmail



Select
 
 s.LastName
,s.FirstName
,s.StateStudentID
,ts.DistrictCode
,ts.SchoolCode
,ContentArea=isnull(t.ContentArea,t.Test)
,ts.Test
,ts.Level
,AssessmentText=isnull(tl.Description,tl.Level) 
,q2.Status
,count(us.TeacherID) AS CurrentUserGroupCount
from Core.Student s
Inner Join TestSession.Links l On l.AdministrationID = s.AdministrationID And l.StudentID = s.StudentID
Inner Join Core.TestSession ts On ts.AdministrationID = l.AdministrationID And ts.TestSessionID = l.TestSessionID
inner join Scoring.Tests t on t.AdministrationID=ts.AdministrationID and t.Test=ts.Test
inner join Scoring.TestLevels tl on tl.AdministrationID=ts.AdministrationID and tl.Test=ts.Test and tl.Level=ts.Level
Inner Join #q q2 On q2.AdministrationID = ts.AdministrationID And q2.TestSessionID = ts.TestSessionID
left join Config.Extensions ext on ext.AdministrationID=tl.AdministrationID and ext.Category='eWeb' and ext.Name=tl.Test + '.' + tl.Level + '.Hide'
left join #UsersStudents us ON s.AdministrationID=us.AdministrationID and s.StudentID=us.StudentID

Where s.AdministrationID = @AdministrationID
And s.DistrictCode = @DistrictCode
And s.SchoolCode = @SchoolCode
And charindex('$',t.ContentArea) =0  
And charindex('$',isnull(tl.Description,tl.Level)) = 0
And isnull(ext.Value, 'N') = 'N'
group by s.LastName,s.FirstName,s.StateStudentID,ts.DistrictCode,ts.SchoolCode
	,isnull(t.ContentArea,t.Test)
	,ts.Test
	,ts.Level
	,isnull(tl.Description,tl.Level) 
	,q2.Status


drop table #q
drop table #UsersStudents


End
GO
