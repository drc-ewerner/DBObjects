USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[IsUserTeacher]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [eWeb].[IsUserTeacher]
	@AdministrationID int,
	@Email varchar(256)
as
begin
/* 08/31/2010 - version 1.0 */
	declare @isTeacherCount int
	
	set @isTeacherCount=
		(select count(*) 
		from Core.Teacher
		where AdministrationID=@AdministrationID and Email=@Email)
		
	if @isTeacherCount > 0
		select 1
	else
		select 0
end
GO
