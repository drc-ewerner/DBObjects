USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_DeleteDocsByVersionKey]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Steve Campbell
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[eweb_DeleteDocsByVersionKey] 
	@versionKey uniqueidentifier 
AS
BEGIN
	DELETE	dgvd
	FROM	DocGroupVersionDoc dgvd
		INNER JOIN Doc d ON dgvd.DocId = d.DocId
	WHERE	d.VersionKey = @versionKey

	DELETE	d
	FROM	Doc d 
	WHERE	d.VersionKey = @versionKey

	--remove publish info which points at nothing
	DELETE	dgvp
	FROM	DocGroupVersionPublish dgvp
		WHERE NOT EXISTS(SELECT * FROM DocGroupVersionDoc dgvd WHERE dgvd.DocGroupVerId = dgvp.DocGroupVerId)

	--remove batches without a version
	DELETE	db
	FROM	DocBatch db
		WHERE NOT EXISTS(SELECT * FROM DocGroupVersionDoc dgvd WHERE dgvd.DocGroupVerId = db.DocGroupVerId)

	--remove versions without docs
	DELETE	dgv
	FROM	DocGroupVersion dgv
		WHERE NOT EXISTS(SELECT * FROM DocGroupVersionDoc dgvd WHERE dgvd.DocGroupVerId = dgv.DocGroupVerId)

	--remove batches with empty groups
	DELETE	db
	FROM	DocBatch db
	WHERE	NOT EXISTS(SELECT * FROM DocGroupVersion dgv WHERE dgv.DocGroupId = db.DocGroupId)

	--remove groups with no versions
	DELETE	dg
	FROM	DocGroup dg
	WHERE	NOT EXISTS(SELECT * FROM DocGroupVersion dgv WHERE dgv.DocGroupId = dg.DocGroupId)
END
GO
