USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetMatchingSchoolTeachers]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* Matching Teachers */
CREATE procedure [eWeb].[GetMatchingSchoolTeachers]
	@AdministrationID int,
	@DistrictCode varchar(15) = null,
	@SchoolCode varchar(15) = null,
	@LastName varchar(100) = null,
	@FirstName varchar(100) = null,
	@Email varchar(256) = null,
	@StateTeacherID varchar(50) = null
WITH RECOMPILE
as
/* 8/31/2010 - Version 1.0 */
begin
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	select LastName,FirstName,Email,StateTeacherID,ts.DistrictCode,ts.SchoolCode,ct.TeacherID,ct.Status
	from Core.Teacher ct
	inner join Teacher.Sites ts on ct.AdministrationID=ts.AdministrationID 
		and ct.TeacherID=ts.TeacherID 
		and (ts.DistrictCode=@DistrictCode or @DistrictCode IS NULL)
		and (ts.SchoolCode=@SchoolCode or @SchoolCode IS NULL)
	where ct.AdministrationID=@AdministrationID and
		LastName like case when @lastName is null then LastName else @lastName end and
		FirstName like case when @firstName is null then FirstName else @firstName end and
		Email like case when @Email is null then Email else @Email end and 
		StateTeacherID like case when @StateTeacherID is null then StateTeacherID else @StateTeacherID end and ct.Status != 'Inactive'
	order by LastName
end
GO
