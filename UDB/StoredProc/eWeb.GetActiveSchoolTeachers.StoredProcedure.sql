USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetActiveSchoolTeachers]    Script Date: 1/12/2022 1:30:38 PM ******/
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
