USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_DeleteDocGroup]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eweb_DeleteDocGroup]
@DocGroupID INT
AS
BEGIN	
	BEGIN TRANSACTION

	--delete all the DocBatch info
    Delete dbo.DocBatch where DocGroupId = @docGroupId
	
	--Next delete all the publishing info
    Delete dgvp
		FROM   dbo.DocGroup dg INNER JOIN
			   dbo.DocGroupVersion dgv ON dg.DocGroupID = dgv.DocGroupID INNER JOIN
			   dbo.DocGroupVersionPublish dgvp  ON dgv.DocGroupVerID = dgvp.DocGroupVerID
		WHERE     (dg.DocGroupID = @docGroupId)

    --Store list of docs in temp table before deleting DocGroupVersionDoc
    DECLARE @docListing TABLE 
	( 
		DocID uniqueidentifier
	)
	Insert @docListing
	SELECT    dbo.DocGroupVersionDoc.DocID 
	FROM         dbo.DocGroup 
		INNER JOIN dbo.DocGroupVersion ON dbo.DocGroup.DocGroupID = dbo.DocGroupVersion.DocGroupID 
		INNER JOIN dbo.DocGroupVersionDoc ON dbo.DocGroupVersion.DocGroupVerID = dbo.DocGroupVersionDoc.DocGroupVerID
	WHERE     (dbo.DocGroup.DocGroupID = @docGroupId)

    --Delete DocGroupVersionDoc
	Delete dgvd
	FROM         dbo.DocGroup dg 
		INNER JOIN dbo.DocGroupVersion dgv ON dg.DocGroupID = dgv.DocGroupID 
		INNER JOIN dbo.DocGroupVersionDoc dgvd ON dgv.DocGroupVerID = dgvd.DocGroupVerID
	WHERE     (dg.DocGroupID = @docGroupId)
 
	--Using temp table delete docs
	Delete x
	From dbo.Doc x 
	inner join @docListing y on	x.DocID = y.DocID

	--Now delete DocGroupVersion
	Delete dbo.DocGroupVersion where DocGroupID = @DocGroupID

	--Now delete DocGroupRoles
	Delete dbo.DocGroupRoles where DocGroupID = @DocGroupID

    --Now delete DocGroup
	Delete dbo.DocGroup where DocGroupId = @docGroupID

	COMMIT TRANSACTION
END
GO
