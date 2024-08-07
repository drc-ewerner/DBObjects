USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentDetails]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetStudentDetails]
@AdministrationID INT, @StudentID INT, @currentUserEmail VARCHAR (256)=null
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

/* 8/31/2010 - Version 1.0 */
	select 
	    cs.AdministrationID
		,cs.StudentID
		,LastName
		,FirstName
		,MiddleName
		,NameSuffix
		,BirthDate
		,cast(isnull(Gender, '') as CHAR(1)) as Gender
		,Grade
		,StateStudentID
		,DistrictStudentID
		,SchoolStudentID
		,DistrictCode
		,SchoolCode
		,VendorStudentID
		,CreateDate
		,UpdateDate
		,se.Category
		,se.Name
		,se.Value
		,(SELECT COUNT(*)
		FROM StudentGroup.Links lnk 
			inner join Teacher.StudentGroups grp ON grp.AdministrationID=lnk.AdministrationID and grp.GroupID=lnk.GroupID
			inner join Core.Teacher teach ON teach.AdministrationID=lnk.AdministrationID and teach.TeacherID=grp.TeacherID
		WHERE teach.Email = @currentUserEmail
		AND lnk.AdministrationID  = @AdministrationID
		AND lnk.StudentID		   = @StudentID)
								AS CurrentUserGroupCount
	from Core.Student cs
	left join Student.Extensions se on se.AdministrationID=cs.AdministrationID and 
		cs.StudentID=se.StudentID 
	where cs.AdministrationID=@AdministrationID and cs.StudentID = @StudentID
END
GO
