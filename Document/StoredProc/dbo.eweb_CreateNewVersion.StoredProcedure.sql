USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_CreateNewVersion]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Steve Campbell
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[eweb_CreateNewVersion] 
	-- Add the parameters for the stored procedure here
	@DocGroupId int = 0
AS
BEGIN
	DECLARE @Version int
	DECLARE @DocGroupVerId int

	SELECT @Version = max(Version)
	FROM	DocGroupVersion
	WHERE	DocGroupId = @DocGroupId

	if @Version IS NULL
	begin
		--new doc group, so just insert a new version record
		INSERT DocGroupVersion(DocGroupId, Version)
		VALUES (@DocGroupId, 1)

		RETURN SCOPE_IDENTITY()
	end
	else
	begin
		INSERT DocGroupVersion(DocGroupId, Version)
		VALUES (@DocGroupId, @Version + 1)

		SELECT @DocGroupVerId = SCOPE_IDENTITY()

		--auto-insert a link to all the old docs for the new version
		INSERT	DocGroupVersionDoc(DocGroupVerId, DocId)
		SELECT	@DocGroupVerId, old.DocId
		FROM	DocGroupVersion prevVer
			INNER JOIN DocGroupVersionDoc old ON old.DocGroupVerId = prevVer.DocGroupVerId
		WHERE	prevVer.Version = @Version
		AND		prevVer.DocGroupId = @DocGroupId

		RETURN @DocGroupVerId
	end
END
GO
