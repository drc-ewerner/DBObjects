USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetMatchingStudentGroupsWithExtensions]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [eWeb].[GetMatchingStudentGroupsWithExtensions]
@AdministrationID INT, 
@DistrictCode varchar(15), 
@SchoolCode varchar(15)=null, 
@TeacherID INT=null, 
@GroupName VARCHAR (200)=null,
@StudentLastName VARCHAR (100)=null, 
@StudentFirstName VARCHAR (100)=null, 
@StateStudentId VARCHAR (20)=null
AS
/* Version 1.1 - SchoolCode optional */
select 
       sg.GroupID,sg.GroupName,sg.SchoolCode,
       sg.GroupType,
       ct.LastName,
       ct.FirstName,
       ct.TeacherID,
       ct.StateTeacherID,
       StudentCount=(select count(*) from studentgroup.links lnk
              inner join core.student s ON s.AdministrationId=lnk.AdministrationID and s.StudentId=lnk.StudentId
              where lnk.AdministrationID=sg.AdministrationID 
              and lnk.GroupID=sg.GroupID),
       ExtensionName = ex.[Name],
       ExtensionValue = ex.[Value]
from Core.StudentGroup sg
inner join Teacher.StudentGroups tsg on tsg.AdministrationID=sg.AdministrationID and tsg.GroupID=sg.GroupID
inner join Core.Teacher ct on ct.AdministrationID=sg.AdministrationID and tsg.TeacherID=ct.TeacherID
left join StudentGroup.Extensions ex on ex.AdministrationID = sg.AdministrationID and ex.GroupID = sg.GroupID
where sg.AdministrationID=@AdministrationID 
and sg.DistrictCode=@DistrictCode 
and ( sg.SchoolCode=@SchoolCode or isnull(@SchoolCode,'')='' ) 
and ( tsg.TeacherID = @TeacherID or isnull(@TeacherID,'')='' ) 
and sg.GroupName like coalesce(@GroupName,sg.GroupName)
and 
( 
	isnull( @StudentLastName, '') =''
	and
	isnull( @StudentFirstName, '') =''
	and
	isnull( @StateStudentId, '') =''
	or
	exists
	(
		select lnk.GroupId from studentgroup.links lnk
		inner join core.student s ON s.AdministrationId=lnk.AdministrationID and s.StudentId=lnk.StudentId
		where lnk.AdministrationID=sg.AdministrationId
		and lnk.GroupID = sg.GroupID
		and coalesce(s.LastName,'') like coalesce(@StudentLastName,s.LastName,'')
		and coalesce(s.FirstName,'') like coalesce(@StudentFirstName,s.FirstName,'')
		and coalesce(s.StateStudentID,'') = coalesce(@StateStudentId,s.StateStudentID,'')
	)
)
--JC - 9/24/13 - PBI 28616
and sg.[GroupType] = 'Roster'
GO
