USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentsNotInUsersGroup]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetStudentsNotInUsersGroup]
@AdministrationID INT, @StudentIDs VARCHAR(MAX), @currentUserEmail VARCHAR (256)=null
AS
BEGIN

SELECT lnk.AdministrationID, lnk.GroupID, lnk.StudentID
FROM StudentGroup.Links lnk 
LEFT OUTER JOIN Teacher.StudentGroups grp ON grp.AdministrationID=lnk.AdministrationID and grp.GroupID=lnk.GroupID
LEFT OUTER JOIN Core.Teacher teach ON teach.AdministrationID=lnk.AdministrationID and teach.TeacherID=grp.TeacherID
	AND teach.Email = @currentUserEmail
WHERE lnk.AdministrationID  = @AdministrationID
	AND lnk.StudentID IN (SELECT * FROM eWeb.ConvertCSVToTable(@StudentIDs, ','))
	AND teach.AdministrationID IS NULL

END
GO
