USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[IsTeacher]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[IsTeacher]
    @AdministrationID int
   ,@DistrictCode varchar(15)
   ,@SchoolCode varchar(15)
   ,@FirstName nvarchar(100)
   ,@LastName nvarchar(100)
   ,@StateTeacherID varchar(50)
   ,@Email varchar(256)
   ,@TeacherID int = 0
as
begin
/* 08/31/2010 - Version 1.0 */
	if exists(select 1
	from Core.Teacher t 
	JOIN Teacher.Sites s on t.TeacherID=s.TeacherID and t.AdministrationID=s.AdministrationID
	WHERE s.AdministrationID=@AdministrationID and
          s.DistrictCode=@DistrictCode and
          s.SchoolCode=@SchoolCode and 
		  t.FirstName=@FirstName and 
          t.LastName=@LastName and 
          t.Email=@Email and 
          t.StateTeacherID=@StateTeacherID and
          (@TeacherID=0 or t.TeacherID<>@TeacherID))
		return 1
	else
		return 0
end
GO
