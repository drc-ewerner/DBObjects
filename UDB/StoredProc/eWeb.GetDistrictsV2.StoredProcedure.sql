USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetDistrictsV2]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[GetDistrictsV2] 
	@AdministrationId INT,
	@StateCode VARCHAR(2) = NULL,
	@DistrictCode VARCHAR(20) = NULL,
	@SiteID UNIQUEIDENTIFIER = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF LTRIM(RTRIM(@StateCode)) = '' SET @StateCode = NULL
	IF LTRIM(RTRIM(@DistrictCode)) = '' SET @DistrictCode = NULL
	IF @SiteID IS NOT NULL
		BEGIN
			SELECT TOP 1
				AdministrationID,
				SiteID,
				SiteCode,
				SiteName,
				StatusID,
				[Status],
				LevelID,
				SiteTypeID,
				SiteType,
				ClientSiteType,
				SiteSubType,
				ChildCount,
				MaterialShipToFlag,
				ReportShipToFlag,
				EarlyReturnPriorityLevel,
				ShippingEstimate,
				SuperSiteCode,
				SuperSiteID,
				CreateDate,
				UpdateDate
			FROM Core.Site WITH(NOLOCK)
			WHERE AdministrationID = @AdministrationId
				AND SiteID = @SiteID
				AND SiteType = 'District'
		END
	ELSE IF @StateCode IS NOT NULL
		BEGIN
			SELECT
				AdministrationID,
				SiteID,
				SiteCode,
				SiteName,
				StatusID,
				[Status],
				LevelID,
				SiteTypeID,
				SiteType,
				ClientSiteType,
				SiteSubType,
				ChildCount,
				MaterialShipToFlag,
				ReportShipToFlag,
				EarlyReturnPriorityLevel,
				ShippingEstimate,
				SuperSiteCode,
				SuperSiteID,
				CreateDate,
				UpdateDate
			FROM Core.Site WITH(NOLOCK)
			WHERE AdministrationID = @AdministrationId
				AND SiteType = 'District'
				AND [Status] = 'Active'
				AND SiteCode LIKE @StateCode + '%'
			ORDER BY SiteName
		END
	ELSE IF @DistrictCode IS NOT NULL
		BEGIN
			SELECT TOP 1
				AdministrationID,
				SiteID,
				SiteCode,
				SiteName,
				StatusID,
				[Status],
				LevelID,
				SiteTypeID,
				SiteType,
				ClientSiteType,
				SiteSubType,
				ChildCount,
				MaterialShipToFlag,
				ReportShipToFlag,
				EarlyReturnPriorityLevel,
				ShippingEstimate,
				SuperSiteCode,
				SuperSiteID,
				CreateDate,
				UpdateDate
			FROM Core.Site WITH(NOLOCK)
			WHERE AdministrationID = @AdministrationId
				AND SiteType = 'District'
				AND [Status] = 'Active'
				AND SiteCode = @DistrictCode
			ORDER BY SiteName
		END
	ELSE 
		BEGIN
			SELECT
				AdministrationID,
				SiteID,
				SiteCode,
				SiteName,
				StatusID,
				[Status],
				LevelID,
				SiteTypeID,
				SiteType,
				ClientSiteType,
				SiteSubType,
				ChildCount,
				MaterialShipToFlag,
				ReportShipToFlag,
				EarlyReturnPriorityLevel,
				ShippingEstimate,
				SuperSiteCode,
				SuperSiteID,
				CreateDate,
				UpdateDate
			FROM Core.Site WITH(NOLOCK)
			WHERE AdministrationID = @AdministrationId
				AND SiteType = 'District'
				AND [Status] = 'Active'
			ORDER BY SiteName
		END
END

GO
