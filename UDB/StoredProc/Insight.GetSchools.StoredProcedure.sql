USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetSchools]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [Insight].[GetSchools] 
	@AdministrationId INT,
	@DistrictId VARCHAR(20)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SELECT
		SiteCode,
		SiteName,
		SuperSiteCode
	FROM
		Core.Site 
	WHERE
		SiteType = 'School' AND
		AdministrationID = @AdministrationId AND
		SuperSiteCode = @DistrictId AND
		Status = 'Active'
	ORDER BY
		SiteName
END
GO
