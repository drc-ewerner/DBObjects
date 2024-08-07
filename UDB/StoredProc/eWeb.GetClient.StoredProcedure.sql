USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetClient]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[GetClient]
	@AdministrationId INT
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
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
	FROM Core.Site 
	WHERE AdministrationID = @AdministrationId
		AND SiteType = 'Client'
		AND [Status] = 'Active'
END;
GO
