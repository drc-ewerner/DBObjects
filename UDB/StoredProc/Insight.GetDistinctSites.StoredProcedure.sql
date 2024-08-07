USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetDistinctSites]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[GetDistinctSites]
	@AdministrationID int=null
	
as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

with GetAllSites as (
select distinct 
	d.SiteCode as DistrictCode,
	d.SiteName as DistrictName,
	s.SiteCode as SchoolCode,
	s.SiteName as SchoolName,
	s.SiteType,
	ROW_NUMBER() over(partition by d.SiteCode, s.SiteCode order by s.UpdateDate desc) as RowRank
from Core.Site d
cross apply (select SiteCode, SiteName, SiteType, UpdateDate from Core.Site where d.AdministrationID=AdministrationID and d.SiteCode=SuperSiteCode and LevelID=2) s
where d.LevelID=1 and (@AdministrationID is null or d.AdministrationID=@AdministrationID) 

union all

select distinct 
	d.SiteCode as DistrictCode,
	d.SiteName as DistrictName,
	'' as SchoolCode,
	'' as SchoolName,
	d.SiteType,
	ROW_NUMBER() over(partition by d.SiteCode order by d.UpdateDate desc) as RowRank
from Core.Site d
where d.LevelID=1 and (@AdministrationID is null or d.AdministrationID=@AdministrationID)
)

select	DistrictCode,
		DistrictName,
		SchoolCode,
		SchoolName,
		SiteType
from GetAllSites
where RowRank = 1
order by DistrictName,SchoolName;
GO
