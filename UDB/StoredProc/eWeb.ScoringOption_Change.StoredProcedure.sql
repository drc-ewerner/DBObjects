USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ScoringOption_Change]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [eWeb].[ScoringOption_Change]
	@AdminID INT, @TestSessionID INT, @NewScoringOption VARCHAR(50), @UserID UniqueIdentifier
AS 
BEGIN
	UPDATE Core.TestSession SET ScoringOption = @NewScoringOption WHERE AdministrationID = @AdminID AND TestSessionID = @TestSessionID
	
	DECLARE @action VARCHAR(200)
	SET @action = '<testSession>Changed scoring option to ' + @NewScoringOption + '</testSession>'

	EXEC eWeb.TestSessionHistory_AddEntry @AdminID, @TestSessionID, @UserID, @action

END

GO
