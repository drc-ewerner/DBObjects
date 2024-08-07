USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetActiveSchoolTeachers]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc [eWeb].[GetActiveSchoolTeachers] (@AdministrationID int,@DistrictCode varchar(15),@SchoolCode varchar(15))
as
select t.TeacherID,t.StateTeacherID,t.LastName,t.FirstName,t.Email
from Core.Teacher t
inner join Teacher.Sites ts on ts.AdministrationID=t.AdministrationID and ts.TeacherID=t.TeacherID
where t.AdministrationID=@AdministrationID and ts.DistrictCode=@DistrictCode and ts.SchoolCode=@SchoolCode
GO
