USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteDocumentExtension]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[DeleteDocumentExtension]
@AdministrationID INT,
@DocumentID INT,
@Name VARCHAR(50)
AS

delete from Document.Extensions
where
	[AdministrationID] = @AdministrationID AND
	[DocumentID] = @DocumentID AND
	[Name] = @Name
GO
