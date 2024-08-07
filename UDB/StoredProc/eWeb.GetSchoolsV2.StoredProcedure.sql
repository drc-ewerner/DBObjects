USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetSchoolsV2]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[GetSchoolsV2] 
	@AdministrationId INT,
	@DistrictCode VARCHAR(20) = NULL,
	@SchoolCode VARCHAR(20) = NULL,
	@StateCode VARCHAR(2) = NULL,
	@SiteID UNIQUEIDENTIFIER = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	IF LTRIM(RTRIM(@DistrictCode)) = '' SET @DistrictCode = NULL
	IF LTRIM(RTRIM(@SchoolCode)) = '' SET @SchoolCode = NULL
	IF LTRIM(RTRIM(@StateCode)) = '' SET @StateCode = NULL
	IF @SiteID IS NOT NULL
		BEGIN
			SELECT TOP 1
				SCH.AdministrationID,
				SCH.SiteID,
				SCH.SiteCode,
				SCH.SiteName,
				SCH.StatusID,
				SCH.[Status],
				SCH.LevelID,
				SCH.SiteTypeID,
				SCH.SiteType,
				SCH.ClientSiteType,
				SCH.SiteSubType,
				SCH.ChildCount,
				SCH.MaterialShipToFlag,
				SCH.ReportShipToFlag,
				SCH.EarlyReturnPriorityLevel,
				SCH.ShippingEstimate,
				SCH.SuperSiteID,
				DIS.SiteCode AS SuperSiteCode,
				DIS.SiteName AS SuperSiteName,
				SCH.CreateDate,
				SCH.UpdateDate
			FROM Core.Site SCH WITH(NOLOCK)
				LEFT JOIN Core.Site DIS WITH(NOLOCK) ON DIS.SiteID = SCH.SuperSiteID 
					AND DIS.AdministrationID = SCH.AdministrationID
			WHERE SCH.AdministrationID = @AdministrationId
				AND SCH.SiteID = @SiteID
				AND SCH.SiteType = 'School' 
		END
	ELSE IF @StateCode IS NOT NULL AND @DistrictCode IS NULL AND @SchoolCode IS NULL
		BEGIN
			SELECT
				SCH.AdministrationID,
				SCH.SiteID,
				SCH.SiteCode,
				SCH.SiteName,
				SCH.StatusID,
				SCH.[Status],
				SCH.LevelID,
				SCH.SiteTypeID,
				SCH.SiteType,
				SCH.ClientSiteType,
				SCH.SiteSubType,
				SCH.ChildCount,
				SCH.MaterialShipToFlag,
				SCH.ReportShipToFlag,
				SCH.EarlyReturnPriorityLevel,
				SCH.ShippingEstimate,
				SCH.SuperSiteID,
				DIS.SiteCode AS SuperSiteCode,
				DIS.SiteName AS SuperSiteName,
				SCH.CreateDate,
				SCH.UpdateDate
			FROM Core.Site SCH WITH(NOLOCK)
				INNER JOIN Core.Site DIS WITH(NOLOCK) ON DIS.SiteID = SCH.SuperSiteID 
					AND DIS.AdministrationID = SCH.AdministrationID
			WHERE SCH.AdministrationID = @AdministrationId 
				AND SCH.[Status] = 'Active'
				AND DIS.SiteType = 'District'
				AND DIS.SiteCode LIKE @StateCode + '%'
			ORDER BY SCH.SiteName
		END
	ELSE IF @SchoolCode IS NOT NULL
		BEGIN
			SELECT TOP 1
				SCH.AdministrationID,
				SCH.SiteID,
				SCH.SiteCode,
				SCH.SiteName,
				SCH.StatusID,
				SCH.[Status],
				SCH.LevelID,
				SCH.SiteTypeID,
				SCH.SiteType,
				SCH.ClientSiteType,
				SCH.SiteSubType,
				SCH.ChildCount,
				SCH.MaterialShipToFlag,
				SCH.ReportShipToFlag,
				SCH.EarlyReturnPriorityLevel,
				SCH.ShippingEstimate,
				SCH.SuperSiteID,
				DIS.SiteCode AS SuperSiteCode,
				DIS.SiteName AS SuperSiteName,
				SCH.CreateDate,
				SCH.UpdateDate
			FROM Core.Site SCH WITH(NOLOCK)
				INNER JOIN Core.Site DIS WITH(NOLOCK) ON DIS.SiteID = SCH.SuperSiteID 
					AND DIS.AdministrationID = SCH.AdministrationID
			WHERE SCH.AdministrationID = @AdministrationId 
				AND SCH.SiteType = 'School' 
				AND SCH.[Status] = 'Active'
				AND SCH.SiteCode = @SchoolCode
				AND DIS.SiteCode = @DistrictCode
			ORDER BY SCH.SiteName
		END
	ELSE
		BEGIN
			SELECT
				SCH.AdministrationID,
				SCH.SiteID,
				SCH.SiteCode,
				SCH.SiteName,
				SCH.StatusID,
				SCH.[Status],
				SCH.LevelID,
				SCH.SiteTypeID,
				SCH.SiteType,
				SCH.ClientSiteType,
				SCH.SiteSubType,
				SCH.ChildCount,
				SCH.MaterialShipToFlag,
				SCH.ReportShipToFlag,
				SCH.EarlyReturnPriorityLevel,
				SCH.ShippingEstimate,
				SCH.SuperSiteID,
				DIS.SiteCode AS SuperSiteCode,
				DIS.SiteName AS SuperSiteName,
				SCH.CreateDate,
				SCH.UpdateDate
			FROM Core.Site SCH WITH(NOLOCK)
				INNER JOIN Core.Site DIS WITH(NOLOCK) ON DIS.SiteID = SCH.SuperSiteID
					 AND DIS.AdministrationID = SCH.AdministrationID
			WHERE SCH.AdministrationID = @AdministrationId 
				AND SCH.SiteType = 'School' 
				AND SCH.[Status] = 'Active'
				AND DIS.SiteCode = @DistrictCode
			ORDER BY SCH.SiteName
		END
END
GO
