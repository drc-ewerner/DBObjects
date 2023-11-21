USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[SNSQueue_SetProcessed]    Script Date: 11/21/2023 8:39:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[SNSQueue_SetProcessed](@UserId UNIQUEIDENTIFIER) AS
BEGIN
	UPDATE dbo.SNSQueue SET Processed = 1, UpdateDate = GETDATE() WHERE UserId = @UserId
END 
GO
