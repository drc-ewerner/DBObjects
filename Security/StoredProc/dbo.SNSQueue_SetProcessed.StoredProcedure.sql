USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[SNSQueue_SetProcessed]    Script Date: 1/12/2022 2:05:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[SNSQueue_SetProcessed](@UserId UNIQUEIDENTIFIER) AS
BEGIN
	UPDATE dbo.SNSQueue SET Processed = 1, UpdateDate = GETDATE() WHERE UserId = @UserId
END 
GO
