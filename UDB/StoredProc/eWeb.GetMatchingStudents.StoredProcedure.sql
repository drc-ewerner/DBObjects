USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetMatchingStudents]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetMatchingStudents]
@AdministrationID INT, @DistrictCode varchar(15)=null, @SchoolCode varchar(15)=null, @LastName VARCHAR (100)=null, @FirstName VARCHAR (100)=null, @StateStudentID VARCHAR (20)=null, @Grade VARCHAR (2)=null, @ExtCategory VARCHAR (50)=null, @ExtName VARCHAR (50)=null, @ExtValue VARCHAR (100)=null, @MaxResults INT, @currentUserEmail VARCHAR (256)=null
AS
begin
/* 8/31/2010 - Version 1.0 */

if (@ExtCategory is not null 
	and @ExtName is not null 
	and @ExtValue is not null)
begin
	with UsersStudents AS (
		select lnk.AdministrationID, lnk.StudentID, teach.TeacherID
		from StudentGroup.Links lnk 
		inner join Teacher.StudentGroups grp ON grp.AdministrationID=lnk.AdministrationID and grp.GroupID=lnk.GroupID
		inner join Core.Teacher teach ON teach.AdministrationID=lnk.AdministrationID and teach.TeacherID=grp.TeacherID
			and teach.Email = @currentUserEmail
	)
	select top(@MaxResults) cs.StudentID,cs.StateStudentID,cs.LastName,cs.FirstName,cs.Grade,cs.BirthDate,cs.DistrictCode,cs.SchoolCode,
		count(us.TeacherID) AS CurrentUserGroupCount
	from Core.Student cs
	inner join Student.Extensions se on se.AdministrationID=cs.AdministrationID and 
		cs.StudentID=se.StudentID and se.Category=@ExtCategory and se.Name=@ExtName and se.Value=@ExtValue
	left join UsersStudents us ON cs.AdministrationID=us.AdministrationID and cs.StudentID=us.StudentID
	where cs.AdministrationID=@AdministrationID and 
		coalesce(cs.DistrictCode,'')=coalesce(@DistrictCode,DistrictCode,'') and
		coalesce(cs.SchoolCode,'')=coalesce(@SchoolCode,SchoolCode,'') and
		cs.LastName like case when @LastName is null then cs.LastName else @LastName end and
		cs.FirstName like case when @FirstName is null then cs.FirstName else @FirstName end and
		cs.StateStudentID like case when @StateStudentID is null then cs.StateStudentID else @StateStudentID end and
		coalesce(cs.Grade,'')=coalesce(@Grade,cs.Grade,'')
	group by cs.StudentID,cs.StateStudentID,cs.LastName,cs.FirstName,cs.Grade,cs.BirthDate,cs.DistrictCode,cs.SchoolCode
end
else
begin

	with UsersStudents AS (
		select lnk.AdministrationID, lnk.StudentID, teach.TeacherID
		from StudentGroup.Links lnk 
		inner join Teacher.StudentGroups grp ON grp.AdministrationID=lnk.AdministrationID and grp.GroupID=lnk.GroupID
		inner join Core.Teacher teach ON teach.AdministrationID=lnk.AdministrationID and teach.TeacherID=grp.TeacherID
			and teach.Email = @currentUserEmail
	)
	select top(@MaxResults) cs.StudentID,cs.StateStudentID,cs.LastName,cs.FirstName,cs.Grade,cs.BirthDate,cs.DistrictCode,cs.SchoolCode,
		count(us.TeacherID) AS CurrentUserGroupCount
	from Core.Student cs
	left join UsersStudents us ON cs.AdministrationID=us.AdministrationID and cs.StudentID=us.StudentID
	where cs.AdministrationID=@AdministrationID and 		
		coalesce(cs.DistrictCode,'')=coalesce(@DistrictCode,DistrictCode,'') and
		coalesce(cs.SchoolCode,'')=coalesce(@SchoolCode,SchoolCode,'') and
		cs.LastName like case when @LastName is null then cs.LastName else @LastName end and
		cs.FirstName like case when @FirstName is null then cs.FirstName else @FirstName end and
		cs.StateStudentID like case when @StateStudentID is null then cs.StateStudentID else @StateStudentID end and
		coalesce(cs.Grade,'')=coalesce(@Grade,cs.Grade,'')
	group by cs.StudentID,cs.StateStudentID,cs.LastName,cs.FirstName,cs.Grade,cs.BirthDate,cs.DistrictCode,cs.SchoolCode
end

end
GO
