USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetMaterialOrderStatus]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [eWeb].[GetMaterialOrderStatus]
@AdminId int,
@DistrictCode as varchar(15),
@SchoolCode as varchar(15),
@AppletCode as varchar(5)
AS

BEGIN
	IF eWeb.GetConfigExtensionValue(@adminID,'eWeb','ConfigUI.EnrollmentsMultipleCompletesReportingEnable', 'N')='N'
	
BEGIN
	SELECT 
		  OrderID
		, AdminID
		, A.Description as AdministrationName
		, EO.StatusID
		, DistrictCode
		, D.SiteName as DistrictName
		, SchoolCode
		, S.SiteName as SchoolName
		, LastUpdateDate
		, AppletCode
		, ExportDate
		, FirstName
		, LastName
		, EmailAddress
		FROM eWeb.EnrollmentOrder EO	
			INNER JOIN Core.Administration A
				ON EO.AdminID = A.AdministrationID
			LEFT JOIN Core.Site D
				ON EO.AdminID = D.AdministrationID AND EO.DistrictCode = D.SiteCode AND D.SiteType = 'District'
			LEFT JOIN Core.Site S on D.AdministrationID = S.AdministrationID and S.SuperSiteCode = DistrictCode and s.SiteCode = SchoolCode
				WHERE EO.AdminID = @AdminId 
				AND (EO.DistrictCode = @DistrictCode OR @DistrictCode = '')
				AND (EO.SchoolCode = @SchoolCode OR @SchoolCode = '')
				AND (EO.AppletCode = @AppletCode)
			ORDER BY DistrictCode, SchoolCode, LastUpdateDate
	END
ELSE

BEGIN
		SELECT 
		  c.OrderID
		, c. AdminID
        , A.Description as AdministrationName
        , EO.StatusID
		, DistrictCode
        , D.SiteName as DistrictName
		, SchoolCode
        , S.SiteName as SchoolName
		, c.LastUpdateDate
        , AppletCode
       , ExportDate
       , c.FirstName
       , c.LastName
       , c.EmailAddress
		FROM eWeb.EnrollmentOrder EO    
			INNER JOIN eWeb.EnrollmentOrderCompletes c
                        ON c.AdminID = eo.AdminID AND c.OrderID = eo.OrderID
			INNER JOIN Core.Administration A
                        ON EO.AdminID = A.AdministrationID
			LEFT JOIN Core.Site D
                 ON EO.AdminID = D.AdministrationID AND EO.DistrictCode = D.SiteCode AND D.SiteType = 'District'
            LEFT JOIN Core.Site S on D.AdministrationID = S.AdministrationID and S.SuperSiteCode = DistrictCode and s.SiteCode = SchoolCode
            WHERE EO.AdminID = @AdminId 
                        AND (EO.DistrictCode = @DistrictCode OR @DistrictCode = '')
                        AND (EO.SchoolCode = @SchoolCode OR @SchoolCode = '')
                        AND (EO.AppletCode = @AppletCode)
					ORDER BY DistrictCode, SchoolCode, LastUpdateDate 
	END
	END
GO
