USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetApprovedDocsBySchool]    Script Date: 1/12/2022 2:12:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[eweb_GetApprovedDocsBySchool] 
	@environmentCode nvarchar(20), 
	@forDate datetime,
	@districtCode nvarchar(30),
	@schoolCode nvarchar(30),
    @superType int = 1,
	@docTypeID int = 0,
	@AdministrationID int =1
AS
BEGIN
	SELECT	d.DocID, d.OriginalFileName, d.FilePath, d.LinkText, d.CreatedDate,
			pub.PublishBeginDate, pub.PublishEndDate, [dbo].[udf_GetViewerRoles](g.DocGroupID) AS ViewerRoles, 
			g.UserGroupID, g.StateRptsViewableByLowerRoles,
			ft.Descr AS FileType, ft.MimeType,
			dt.Descr AS DocType,g.AdministrationID,
			g.Descr AS GroupDescr, ft.FileTypeExt AS FileTypeExt,
			d.DistrictCode,d.SchoolCode,x.DocGroupVerID
	FROM	Doc d
	INNER JOIN DocGroupVersionDoc x ON x.DocID = d.DocID
	INNER JOIN DocGroupVersion ver ON x.DocGroupVerID = ver.DocGroupVerID
	INNER JOIN DocGroupVersionPublish pub ON pub.DocGroupVerID = x.DocGroupVerID
	INNER JOIN DocGroup g ON g.DocGroupId = ver.DocGroupId
	INNER JOIN FileType ft ON g.FileTypeExt = ft.FileTypeExt
	INNER JOIN DocType dt ON g.DocTypeId = dt.DocTypeId
	WHERE	pub.EnvironmentCode = @environmentCode
	AND		@forDate BETWEEN pub.PublishBeginDate AND pub.PublishEndDate
	AND		pub.ApprovedDate IS NOT NULL
	AND		((d.DistrictCode = @districtCode AND	d.SchoolCode = @schoolCode)
			OR (d.DistrictCode='' and d.SchoolCode = ''))
    AND     dt.DocSuperTypeID = @superType
	AND		ver.Version = dbo.eweb_fn_GetApprovedGroupVersion(g.DocGroupId, @forDate, @environmentCode)
	AND		((dt.DocTypeId = @docTypeID) or (@docTypeID = 0))
	AND (g.AdministrationID = @AdministrationID)
    AND x.IsActive = 1
	and	 dt.Status = 'Active'
END
GO
