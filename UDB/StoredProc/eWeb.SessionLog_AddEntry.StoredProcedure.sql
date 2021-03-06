USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SessionLog_AddEntry]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [eWeb].[SessionLog_AddEntry]
	@AdminID INT, @TestSessionID INT, @Username NVARCHAR(256), @Action VARCHAR(200)
AS 
BEGIN
	INSERT INTO eWeb.SessionLog(AdminID, TestSessionID, Username, [Action], [ActionDateTime])
	SELECT @AdminID
		, @TestSessionID
		, @Username
		, @Action
		, GETDATE()
END
GO
