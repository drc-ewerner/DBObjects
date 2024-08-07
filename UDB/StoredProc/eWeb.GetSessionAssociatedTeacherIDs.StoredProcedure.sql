USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetSessionAssociatedTeacherIDs]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetSessionAssociatedTeacherIDs]

@AdministrationID INT

AS

SELECT DISTINCT
	[TeacherID]
FROM
	[Core].[TestSession]
WHERE
	[AdministrationID] = @AdministrationID
ORDER BY
	[TeacherID]
GO
