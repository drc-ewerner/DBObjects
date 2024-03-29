USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetDocSecurityAttribsByVersionKey]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eweb_GetDocSecurityAttribsByVersionKey] 
	-- Add the parameters for the stored procedure here
	@versionKey uniqueidentifier
AS
BEGIN
	SELECT	DISTINCT g.DocGroupID, 
			g.AdministrationID,
			d.DistrictCode, d.SchoolCode,	
			[dbo].[udf_GetViewerRoles](g.DocGroupID) AS ViewerRoles
	FROM	Doc d
	INNER JOIN DocGroupVersionDoc x ON x.DocID = d.DocID
	INNER JOIN DocGroupVersion ver ON x.DocGroupVerID = ver.DocGroupVerID
	INNER JOIN DocGroupVersionPublish pub ON pub.DocGroupVerID = x.DocGroupVerID
	INNER JOIN DocGroup g ON g.DocGroupId = ver.DocGroupId
	WHERE	d.VersionKey = @versionKey
END
GO
