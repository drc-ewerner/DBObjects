USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetReadonlyTeacherIds]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetReadonlyTeacherIds] (
@administrationID int)
AS

/* Version 1.0 - returns the teacher ids that are linked to stateteam groups */

select distinct tsg.TeacherId
from Teacher.StudentGroups tsg
	INNER JOIN StudentGroup.Extensions ext ON ext.AdministrationID=tsg.AdministrationID
		AND ext.GroupId=tsg.GroupID 
		AND ext.Name='Source' and ext.Value='StateTeam'
where tsg.AdministrationID=@administrationID
GO
