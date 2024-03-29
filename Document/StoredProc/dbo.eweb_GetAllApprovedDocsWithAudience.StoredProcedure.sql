USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetAllApprovedDocsWithAudience]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eweb_GetAllApprovedDocsWithAudience]  
	@environmentCode nvarchar(20), 
	@forDate datetime,
    @superType int = 1,
	@docTypeID int = 0,
	@audienceID int = 0
	WITH RECOMPILE
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	CREATE TABLE #DocGroupIDVersion
	(   DocGroupId   INT,
		[Version]    INT,
	)
	CREATE INDEX index1 ON #DocGroupIDVersion (DocGroupId, [Version]);

	INSERT INTO #DocGroupIDVersion
	SELECT Dg.DocGroupId, max(dgv.Version) 
	FROM    DocGroup  Dg
	INNER JOIN 	DocGroupVersion dgv         ON Dg.DocGroupId = dgv.DocGroupID
	INNER JOIN  DocGroupVersionPublish dgvp ON dgv.DocGroupVerId = dgvp.DocGroupVerId
	where	dgvp.PublishBeginDate <= @forDate 
	AND		dgvp.PublishEndDate > @forDate 
	and		dgvp.ApprovedDate is not null
	and		dgvp.EnvironmentCode = @environmentCode
	GROUP BY  Dg.DocGroupId

	SELECT	d.DocID, d.OriginalFileName, d.FilePath, d.LinkText, d.CreatedDate,
			pub.PublishBeginDate, pub.PublishEndDate, [dbo].[udf_GetViewerRoles](g.DocGroupID) AS ViewerRoles,
			g.UserGroupID, g.IsPublic, g.StateRptsViewableByLowerRoles,
			ft.Descr AS FileType, ft.MimeType,
			dt.Descr AS DocType,g.AdministrationID,
			g.Descr as GroupDescr, ft.FileTypeExt AS FileTypeExt,
			d.DistrictCode,d.SchoolCode,ver.DocGroupVerID, aud.Descr as Audience
	FROM	Doc d
	INNER JOIN DocGroupVersionDoc x ON x.DocID = d.DocID
	INNER JOIN DocGroupVersion ver ON x.DocGroupVerID = ver.DocGroupVerID
	INNER JOIN DocGroupVersionPublish pub ON pub.DocGroupVerID = x.DocGroupVerID
	INNER JOIN DocGroup g ON g.DocGroupId = ver.DocGroupId
	INNER JOIN FileType ft ON g.FileTypeExt = ft.FileTypeExt
	INNER JOIN DocType dt ON g.DocTypeId = dt.DocTypeId
	INNER JOIN #DocGroupIDVersion dgv ON dgv.DocGroupId = g.DocGroupId  AND  dgv.Version = ver.Version  
	LEFT JOIN  Audience aud ON g.AudienceID = aud.AudienceID
	WHERE	
	--pub.EnvironmentCode = @environmentCode
	--AND		@forDate BETWEEN pub.PublishBeginDate AND pub.PublishEndDate
	--AND		pub.ApprovedDate IS NOT NULL AND 
	dt.DocSuperTypeID = @superType
	--AND		ver.Version = dbo.eweb_fn_GetApprovedGroupVersion(g.DocGroupId, @forDate, @environmentCode)
	AND		((dt.DocTypeId = @docTypeID) or (@docTypeID = 0))
	AND		((aud.AudienceID = @audienceID) or (@audienceID = 0))
	and		dt.Status = 'Active'
END
GO
