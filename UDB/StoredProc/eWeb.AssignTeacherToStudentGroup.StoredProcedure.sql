USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[AssignTeacherToStudentGroup]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[AssignTeacherToStudentGroup]
    @AdministrationID   int
   ,@GroupID   int
   ,@TeacherID int

AS
BEGIN

	SET NOCOUNT ON

	update Teacher.StudentGroups
    set TeacherID  = @TeacherID,UpdateDate = getdate()
    where AdministrationID = @AdministrationID and GroupID = @GroupID

END
GO
