USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetApprovedDocByVersionKey]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eweb_GetApprovedDocByVersionKey] 
	-- Add the parameters for the stored procedure here
	@versionKey uniqueidentifier,
	@asAtDate datetime, 
	@environmentCode nvarchar(20)
AS
BEGIN
	SELECT	d.DocID, d.OriginalFileName, d.FilePath, d.LinkText, 
			pub.PublishBeginDate, [dbo].[udf_GetViewerRoles](g.DocGroupID) AS ViewerRoles, 
			ft.Descr AS FileType, ft.MimeType,
			dt.Descr AS DocType, g.AdministrationID,
			g.Descr as Description, 
			d.DistrictCode, d.SchoolCode, ver.Version
	FROM	Doc d
	INNER JOIN DocGroupVersionDoc x ON x.DocID = d.DocID
	INNER JOIN DocGroupVersion ver ON x.DocGroupVerID = ver.DocGroupVerID
	INNER JOIN DocGroupVersionPublish pub ON pub.DocGroupVerID = x.DocGroupVerID
	INNER JOIN DocGroup g ON g.DocGroupId = ver.DocGroupId
	INNER JOIN FileType ft ON g.FileTypeExt = ft.FileTypeExt
	INNER JOIN DocType dt ON g.DocTypeId = dt.DocTypeId
	WHERE	pub.EnvironmentCode = @environmentCode
	AND		@asAtDate >= pub.PublishBeginDate 
	AND		@asAtDate < pub.PublishEndDate
	AND		pub.ApprovedDate IS NOT NULL
	AND		ver.Version = dbo.eweb_fn_GetApprovedGroupVersion(g.DocGroupId, @asAtDate, @environmentCode)
	AND		d.VersionKey = @versionKey
END
GO
