USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetDistricts]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [Insight].[GetDistricts] 
	@AdministrationId INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SELECT
		SiteCode,
		SiteName
	FROM
		Core.Site 
	WHERE
		SiteType = 'District' AND
		AdministrationID = @AdministrationId AND
		Status = 'Active'
	ORDER BY
		SiteName
END
GO
