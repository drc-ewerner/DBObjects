USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[SNSQueue_SetProcessed]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[SNSQueue_SetProcessed](@UserId UNIQUEIDENTIFIER) AS
BEGIN
	UPDATE dbo.SNSQueue SET Processed = 1, UpdateDate = GETDATE() WHERE UserId = @UserId
END 
GO
