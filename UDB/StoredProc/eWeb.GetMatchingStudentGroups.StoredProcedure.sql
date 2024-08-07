USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetMatchingStudentGroups]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [eWeb].[GetMatchingStudentGroups] 
@AdministrationID INT, @DistrictCode varchar(15), @SchoolCode varchar(15), @TeacherID INT=null, @GroupName VARCHAR (200)=null
AS
select 
       sg.GroupID,sg.GroupName,sg.GroupType,ct.LastName,ct.FirstName,ct.TeacherID,ct.StateTeacherID,
       StudentCount=(select count(*) from studentgroup.links lnk
              inner join core.student s ON s.AdministrationId=lnk.AdministrationID and s.StudentId=lnk.StudentId
              where lnk.AdministrationID=sg.AdministrationID 
              and lnk.GroupID=sg.GroupID)
from Core.StudentGroup sg
inner join Teacher.StudentGroups tsg on tsg.AdministrationID=sg.AdministrationID and tsg.GroupID=sg.GroupID
inner join Core.Teacher ct on ct.AdministrationID=sg.AdministrationID and tsg.TeacherID=ct.TeacherID
where sg.AdministrationID=@AdministrationID and sg.DistrictCode=@DistrictCode and
       sg.SchoolCode=@SchoolCode and ( tsg.TeacherID = @TeacherID or isnull(@TeacherID,'')='' ) and coalesce(sg.GroupName,'') like coalesce(@GroupName,sg.GroupName,'')
           --JC - 9/24/13 - PBI 28616
	   and sg.[GroupType] = 'Roster'
GO
