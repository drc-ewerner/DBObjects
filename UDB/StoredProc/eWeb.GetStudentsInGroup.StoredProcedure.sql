USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentsInGroup]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[GetStudentsInGroup]
@AdministrationID INT, @GroupID INT
AS
begin
       
       /* 08/18/2010 - Version 1.0 */
       /* 01/03/2011 - Version 2.0 -- Changed to allow students outside the group's site */
       select s.StudentID,s.StateStudentID,s.LastName,s.FirstName,s.Grade,s.DistrictCode,s.SchoolCode
       from Core.StudentGroup g
              inner join StudentGroup.Links k on k.AdministrationID=g.AdministrationID and k.GroupID=g.GroupID
              inner join Core.Student s on s.AdministrationID=g.AdministrationID and s.StudentID=k.StudentID 
       where g.AdministrationID=@AdministrationID and g.GroupID=@GroupID
end
GO
