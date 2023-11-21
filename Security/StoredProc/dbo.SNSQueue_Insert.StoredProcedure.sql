USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[SNSQueue_Insert]    Script Date: 11/21/2023 8:39:10 AM ******/
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
