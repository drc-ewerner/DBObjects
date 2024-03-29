USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteStudentExtension]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[DeleteStudentExtension]
@AdministrationID INT,
@StudentID INT,
@Category VARCHAR(50),
@Name VARCHAR(50)

AS
	delete from Student.Extensions
	where
		[AdministrationID] = @AdministrationID AND
		[StudentID] = @StudentID AND
		[Category] = @Category AND
		[Name] = @Name
GO
