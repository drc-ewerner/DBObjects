USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_DeleteUnpublishedDocuments]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[eweb_DeleteUnpublishedDocuments] 
AS
BEGIN

	DELETE	dgvd
	FROM	DocGroupVersionDoc dgvd
	WHERE	NOT EXISTS(SELECT * FROM DocGroupVersionPublish dgvp WHERE dgvp.DocGroupVerId = dgvd.DocGroupVerId)

	DELETE	db
	FROM	DocBatch db
	WHERE	NOT EXISTS(SELECT * FROM DocGroupVersionPublish dgvp WHERE dgvp.DocGroupVerId = db.DocGroupVerId)

	DELETE	dgv
	FROM	DocGroupVersion dgv
	WHERE	NOT EXISTS(SELECT * FROM DocGroupVersionPublish dgvp WHERE dgvp.DocGroupVerId = dgv.DocGroupVerId)

	DELETE	d
	FROM	Doc d
	WHERE	NOT EXISTS(SELECT * FROM DocGroupVersionDoc dgvd WHERE dgvd.DocId = d.DocId)

	DELETE	db
	FROM	DocBatch db
	WHERE	NOT EXISTS(SELECT * FROM DocGroupVersion dgv WHERE dgv.DocGroupId = db.DocGroupId)

	DELETE	dgr
	FROM	DocGroupRoles dgr
	WHERE	NOT EXISTS(SELECT * FROM DocGroupVersion dgv WHERE dgv.DocGroupId = dgr.DocGroupId)

	DELETE	dg
	FROM	DocGroup dg
	WHERE	NOT EXISTS(SELECT * FROM DocGroupVersion dgv WHERE dgv.DocGroupId = dg.DocGroupId)
END
GO
