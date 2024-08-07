USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetRosterGroupsForSite]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetRosterGroupsForSite]
@AdministrationID INT, 
@DistrictCode varchar(15), 
@SchoolCode varchar(15)=null 
AS
begin
       /* 6/29/2011 - Version 1.0 */
       select s.StudentID, s.StateStudentId, sg.GroupID,sg.GroupName, sg.DistrictCode, sg.SchoolCode, ct.LastName,ct.FirstName,ct.TeacherID,ct.StateTeacherID
       from Core.StudentGroup sg
       inner join Teacher.StudentGroups tsg on tsg.AdministrationID=sg.AdministrationID and
              tsg.GroupID=sg.GroupID
       inner join Core.Teacher ct on ct.AdministrationID=sg.AdministrationID and
              tsg.TeacherID=ct.TeacherID 
       inner join studentgroup.links sl ON sl.AdministrationID = sg.AdministrationID AND 
              sl.GroupID = sg.GroupID
       inner join Core.Student s ON s.AdministrationID=sg.AdministrationID and s.StudentId=sl.StudentID
       where sg.AdministrationID=@AdministrationID and sg.GroupType = 'Roster' and
       sg.DistrictCode=@DistrictCode and
	   coalesce(sg.SchoolCode,'')=coalesce(@SchoolCode,sg.SchoolCode,'')
end
GO
