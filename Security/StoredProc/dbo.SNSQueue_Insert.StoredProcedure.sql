USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[SNSQueue_Insert]    Script Date: 1/12/2022 2:05:17 PM ******/
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
