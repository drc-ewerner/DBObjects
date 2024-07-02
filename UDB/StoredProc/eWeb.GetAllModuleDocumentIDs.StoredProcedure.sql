USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAllModuleDocumentIDs]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [eWeb].[GetAllModuleDocumentIDs]
	@documentID int
as


Declare @studentID int
Declare @sessionID int
  
Select @studentID=StudentID from TestSession.Links where documentid=@documentID
Select @sessionID= TestSessionID from TestSession.Links where documentid=@documentID
 

Select DocumentID from TestSession.Links where StudentID=@StudentId and TestSessionID=@sessionID
GO
