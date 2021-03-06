USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetDistricts]    Script Date: 1/12/2022 1:30:39 PM ******/
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
