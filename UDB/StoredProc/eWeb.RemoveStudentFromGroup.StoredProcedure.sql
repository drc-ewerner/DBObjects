USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[RemoveStudentFromGroup]    Script Date: 1/12/2022 1:30:38 PM ******/
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
