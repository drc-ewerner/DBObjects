USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteStudentGroup]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[DeleteStudentGroup]
	@AdministrationID int,
	@GroupID int
as
/* 8/31/2010 - Version 1.0 */
/* These should be cascaded and have foreign keys added to the tables */
begin	
	delete from studentgroup.extensions where GroupID=@GroupID and AdministrationID=@AdministrationID
	delete from StudentGroup.Links where GroupID = @GroupID and AdministrationID=@AdministrationID
	delete from Core.studentgroup where GroupID=@GroupID and AdministrationID=@AdministrationID
end
GO
