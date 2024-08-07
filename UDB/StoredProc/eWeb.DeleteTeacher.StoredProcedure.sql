USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteTeacher]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[DeleteTeacher]
	@AdministrationID int,
	@DistrictCode varchar(15),
	@SchoolCode varchar(15),
	@TeacherID int
as
begin	
	set xact_abort on;
	begin transaction

	delete from Core.studentgroup 
	where 
		AdministrationID=@AdministrationID and
		DistrictCode = @DistrictCode and
		SchoolCode = @SchoolCode and			
		GroupID in (
			select GroupID from Teacher.StudentGroups 
			where AdministrationID=@AdministrationID and TeacherID=@TeacherID
		)


	update Core.TestSession
	set TeacherID = NULL 
	where 
		AdministrationID=@AdministrationID and
		TeacherID = @TeacherID and
		DistrictCode = @DistrictCode and
		SchoolCode = @SchoolCode


	delete from teacher.sites 
	where 
		AdministrationID=@AdministrationID and
		TeacherID = @TeacherID and
		DistrictCode = @DistrictCode and
		SchoolCode = @SchoolCode
		
		
		delete from core.teacher where 
			AdministrationID=@AdministrationID and
			TeacherID = @TeacherID and 
			TeacherID not in (
				select TeacherID from teacher.sites where 
					AdministrationID=@AdministrationID and
					TeacherID = @TeacherID			
			)
		
	commit transaction
end
GO
