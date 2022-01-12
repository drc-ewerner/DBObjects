USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateStudentGroup]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[UpdateStudentGroup]
@AdministrationID INT, @GroupID INT, @TeacherID INT, @GroupName VARCHAR (200)
AS
update Core.StudentGroup
set GroupName=@GroupName,UpdateDate=getdate()
where AdministrationID=@AdministrationID and GroupID=@GroupID and GroupName<>@GroupName

--assume one teacher per group
update Teacher.StudentGroups
set TeacherID=@TeacherID,UpdateDate=getdate()
where AdministrationID=@AdministrationID and GroupID=@GroupID
GO
