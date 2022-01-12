USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_DeleteEnvironment]    Script Date: 1/12/2022 2:12:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Steve Campbell
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[eweb_DeleteEnvironment] 
	-- Add the parameters for the stored procedure here
	@environment nvarchar(20)
AS
BEGIN
	DELETE	DocGroupVersionPublish
	WHERE	EnvironmentCode = @environment

	EXEC eweb_DeleteUnpublishedDocuments
END
GO
