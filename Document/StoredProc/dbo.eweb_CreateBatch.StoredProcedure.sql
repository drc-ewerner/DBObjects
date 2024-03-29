USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_CreateBatch]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Steve Campbell
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[eweb_CreateBatch] 
	@DocGroupId int, 
	@DocGroupVerId bigint, 
	@DocSource nvarchar(35), 
	@BatchName nvarchar(50)
AS
BEGIN

	IF NOT EXISTS(SELECT * FROM DocSource WHERE Descr = @DocSource)
		INSERT DocSource(Descr) VALUES (@DocSource)

	INSERT	DocBatch(BatchName, DocSourceId, CreateDate, DocGroupID, DocGroupVerId)
	SELECT	@BatchName, ds.DocSourceId, getdate(), @DocGroupId, @DocGroupVerId
	FROM	DocSource ds
	WHERE	ds.Descr = @DocSource

	RETURN SCOPE_IDENTITY()
END
GO
