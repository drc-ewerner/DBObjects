USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[FixPrintOnDemandRequest]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [eWeb].[FixPrintOnDemandRequest]
(
	@AdminID INT, @RequestID INT, @NewForm VARCHAR(20)
)
AS
BEGIN 
	UPDATE Insight.PrintOnDemandRequest
	SET [Form] = @NewForm
	WHERE AdministrationID = @AdminID
		AND RequestID = @RequestID
END
GO
