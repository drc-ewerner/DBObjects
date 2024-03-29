USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetApprovedDocsByDistrictForDistrict]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[eweb_GetApprovedDocsByDistrictForDistrict]  --'UAT','10/23/2008 12:00:00 PM','1702',1
	@environmentCode nvarchar(20), 
	@forDate datetime,
	@districtCode nvarchar(30),
    @superType int = 1,
	@docTypeID int = 0,
	@AdministrationID int = 1
AS
BEGIN

	CREATE TABLE #DocGroupIDVersion
	(   DocGroupId   INT,
		[Version]    INT,
	)
	CREATE INDEX index1 ON #DocGroupIDVersion (DocGroupId, [Version]);

	INSERT INTO #DocGroupIDVersion
	SELECT Dg.DocGroupId, max(dgv.Version) 
	FROM    DocGroup  Dg WITH (NOLOCK)
	INNER JOIN 	DocGroupVersion dgv WITH (NOLOCK) ON Dg.DocGroupId = dgv.DocGroupID
	INNER JOIN  DocGroupVersionPublish dgvp WITH (NOLOCK) ON dgv.DocGroupVerId = dgvp.DocGroupVerId
	where	dgvp.PublishBeginDate <= @forDate 
	AND		dgvp.PublishEndDate > @forDate 
	and		dgvp.ApprovedDate is not null
	and		dgvp.EnvironmentCode = @environmentCode
	GROUP BY  Dg.DocGroupId

	SELECT	d.DocID, d.OriginalFileName, d.FilePath, d.LinkText, d.CreatedDate,
			pub.PublishBeginDate, pub.PublishEndDate, [dbo].[udf_GetViewerRoles](g.DocGroupID) AS ViewerRoles, 
			g.UserGroupID, g.StateRptsViewableByLowerRoles,
			ft.Descr AS FileType, ft.MimeType,
			dt.Descr AS DocType,g.AdministrationID,
			g.Descr as GroupDescr, ft.FileTypeExt AS FileTypeExt,
			d.DistrictCode,d.SchoolCode,x.DocGroupVerID
	FROM	Doc d
	INNER JOIN DocGroupVersionDoc x WITH (NOLOCK) ON x.DocID = d.DocID
	INNER JOIN DocGroupVersion ver WITH (NOLOCK) ON x.DocGroupVerID = ver.DocGroupVerID
	INNER JOIN DocGroupVersionPublish pub WITH (NOLOCK) ON pub.DocGroupVerID = x.DocGroupVerID
	INNER JOIN DocGroup g WITH (NOLOCK) ON g.DocGroupId = ver.DocGroupId
	INNER JOIN FileType ft WITH (NOLOCK) ON g.FileTypeExt = ft.FileTypeExt
	INNER JOIN DocType dt WITH (NOLOCK) ON g.DocTypeId = dt.DocTypeId
	INNER JOIN #DocGroupIDVersion dgv ON dgv.DocGroupId = g.DocGroupId  AND  dgv.Version = ver.Version  
	WHERE	pub.EnvironmentCode = @environmentCode
	AND		@forDate BETWEEN pub.PublishBeginDate AND pub.PublishEndDate
	AND		pub.ApprovedDate IS NOT NULL
	AND		(d.DistrictCode = @districtCode OR (d.DistrictCode='' and d.SchoolCode = ''))
    AND     dt.DocSuperTypeID = @superType
	--AND		ver.Version = dbo.eweb_fn_GetApprovedGroupVersion(g.DocGroupId, @forDate, @environmentCode)
	AND		((dt.DocTypeId = @docTypeID) or (@docTypeID = 0))
	AND (g.AdministrationID = @AdministrationID)
    AND X.IsActive =1
	and		dt.Status = 'Active'
END
GO
