USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[AssignStudentToGroup]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[AssignStudentToGroup]
@AdministrationID INT, @GroupID INT, @StudentID INT
AS
insert StudentGroup.Links(AdministrationID,GroupID,StudentID)
select @AdministrationID, @GroupID, @StudentID
GO
