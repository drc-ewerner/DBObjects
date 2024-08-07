USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentByStateStudentID]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[GetStudentByStateStudentID]
      @AdministrationID  int
     ,@StateStudentID    varchar(20)
AS

SET NOCOUNT ON

SELECT s.AdministrationID
      ,s.StudentID
      ,s.FirstName
      ,s.LastName
      ,s.BirthDate
FROM Core.Student s
WHERE s.AdministrationID = @AdministrationID
  AND s.StateStudentID   = @StateStudentID
GO
