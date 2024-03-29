USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_StoreDocument]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eweb_StoreDocument] 
	-- Add the parameters for the stored procedure here
	@DocGroupVerId int,  
	@OriginalFileName nvarchar(200), 
	@FilePath nvarchar(1200), 
	@LinkText nvarchar(100), 
	@DistrictCode nvarchar(15), 
	@SchoolCode nvarchar(15), 
	@OptionKey nvarchar(35), 
	@VersionKey uniqueidentifier, 
	@createdDate datetime
AS
BEGIN
	declare @DocId uniqueidentifier
	select @DocId = newid()

	declare @FirstDoc BIT
	IF EXISTS(
		SELECT * FROM DocGroupVersion dgv1 
			INNER JOIN DocGroupVersion dgv2 ON dgv2.DocGroupId = dgv1.DocGroupId
			INNER JOIN DocGroupVersionDoc dgvd2 ON dgvd2.DocGroupVerId = dgv2.DocGroupVerId
			INNER JOIN Doc d2 ON d2.DocId = dgvd2.DocId
		WHERE d2.VersionKey = @VersionKey
		AND	dgv1.DocGroupVerID = @DocGroupVerId
	)

		SELECT @FirstDoc = 0	--another doc with this version key exists
	else
		SELECT @FirstDoc = 1	--first doc with this versionkey

	INSERT	Doc(DocId,OriginalFileName, FilePath, LinkText, DistrictCode, SchoolCode, OptionKey, VersionKey, CreatedDate)
	VALUES	(@DocId,@OriginalFileName, @FilePath, @LinkText, @DistrictCode, @SchoolCode, @OptionKey, @VersionKey, @CreatedDate)

	IF @FirstDoc = 1
		--this is the first doc with this version key
		INSERT	DocGroupVersionDoc(DocGroupVerId, DocId)
		VALUES	(@DocGroupVerId, @DocId)
	else
		/*
		Another doc already existed, so we must adjust the current version to point to 
		our new doc instead.
		*/
		UPDATE	dgvd 
		SET		dgvd.DocId = @DocId
		FROM	DocGroupVersionDoc dgvd
			INNER JOIN Doc ON doc.DocId = dgvd.DocId
		WHERE	doc.VersionKey = @VersionKey
		and		dgvd.DocGroupVerId = @DocGroupVerId
END
GO
