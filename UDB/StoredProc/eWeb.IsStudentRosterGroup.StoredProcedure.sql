USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[IsStudentRosterGroup]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [eWeb].[IsStudentRosterGroup]
    @AdministrationID int
   ,@DistrictCode varchar(15)
   ,@SchoolCode varchar(15)
   ,@TeacherID int
   ,@GroupName nvarchar(100)
   ,@GroupID int = 0
as
begin
/* 08/31/2010 - Version 1.0 */
/* 03/01/2011 - Version 1.1 */
	if exists
	( 
		select 1
		from Core.StudentGroup sg 
		inner join Teacher.StudentGroups st on st.GroupID=sg.GroupID and st.AdministrationID=sg.AdministrationID
		where st.AdministrationID=@AdministrationID 
		and st.TeacherID=@TeacherID 
		and sg.DistrictCode=@DistrictCode 
		and sg.SchoolCode=@SchoolCode
		and sg.GroupName=@GroupName
		and sg.GroupType='Roster'
		and ( @GroupID=0 or sg.GroupID<>@GroupID )
	) 
		return 1
	else
		return 0
	
end
GO
