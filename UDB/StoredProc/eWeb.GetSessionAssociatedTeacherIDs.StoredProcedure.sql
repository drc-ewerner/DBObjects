USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetSessionAssociatedTeacherIDs]    Script Date: 1/12/2022 1:30:38 PM ******/
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
