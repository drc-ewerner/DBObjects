USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAdminSitesByState]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[GetAdminSitesByState]
	@AdministrationId INT,
	@StateCode VARCHAR(2) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    IF @StateCode IS NULL SET @StateCode = ''
	SELECT
		S.AdministrationID,
		S.SiteID,
		S.SiteCode,
		S.SiteName,
		S.StatusID,
		S.[Status],
		S.LevelID,
		S.SiteTypeID,
		S.SiteType,
		S.ClientSiteType,
		S.SiteSubType,
		S.ChildCount,
		S.MaterialShipToFlag,
		S.ReportShipToFlag,
		S.EarlyReturnPriorityLevel,
		S.ShippingEstimate,
		S.SuperSiteID,
		P.SiteCode AS SuperSiteCode,
		P.SiteName AS SuperSiteName,
		S.CreateDate,
		S.UpdateDate
	FROM Core.Site S WITH(NOLOCK)
		LEFT JOIN Core.Site P WITH(NOLOCK) ON P.SiteID = S.SuperSiteID 
			AND P.AdministrationID = S.AdministrationID
	WHERE S.AdministrationID = @AdministrationId
		AND (
			S.LevelID = 0 OR
			(S.LevelID = 1 AND S.SiteCode LIKE @StateCode + '%') OR
			(S.LevelID = 2 AND P.SiteCode LIKE @StateCode + '%')
		)
	ORDER BY S.LevelID, P.SiteName, P.SiteID, S.SiteName, S.SiteID
END
GO
