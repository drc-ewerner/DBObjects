USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[SNSQueue_Insert]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[SNSQueue_Insert](@UserId UNIQUEIDENTIFIER) AS
BEGIN
	INSERT INTO dbo.SNSQueue(UserId, CreateDate, UpdateDate, Processed)
	SELECT @UserId, GETDATE(), GETDATE(), 0
END
GO
