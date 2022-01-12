USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[AssignStudentToGroup]    Script Date: 1/12/2022 1:30:38 PM ******/
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
