USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[RemoveStudentFromGroup]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[RemoveStudentFromGroup]
@administrationID INT, @groupID INT, @studentID INT
AS
DELETE StudentGroup.Links
where AdministrationID = @administrationID
and groupID = @groupID
and studentID = @studentId
GO
