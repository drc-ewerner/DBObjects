USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTeacher]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [eWeb].[GetTeacher]
	@AdministrationID int,
	@TeacherID int
as
/* 8/31/2010 - Version 1.0 */
begin
	select StateTeacherID,LastName,FirstName,MiddleName,Email,Status,ts.DistrictCode,ts.SchoolCode
	from Core.Teacher ct
	inner join Teacher.Sites ts on ct.AdministrationID=ts.AdministrationID and ct.TeacherID=ts.TeacherID 
	where ct.AdministrationID=@AdministrationID and ct.TeacherID=@TeacherID
end
GO
