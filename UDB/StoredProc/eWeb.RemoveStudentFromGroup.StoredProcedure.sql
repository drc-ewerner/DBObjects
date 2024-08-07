USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[RemoveStudentFromGroup]    Script Date: 7/2/2024 9:21:54 AM ******/
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
