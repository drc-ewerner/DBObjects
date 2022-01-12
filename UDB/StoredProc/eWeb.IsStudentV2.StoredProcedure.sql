USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[IsStudentV2]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[IsStudentV2]
      @AdministrationID  int,
      @StateStudentID varchar(50),
	  @StudentID int=0

as

declare @id int

	select top(1) di.SiteName DistrictName,sch.SiteName SchoolName,di.SiteCode DistrictCode,sch.SiteCode SchoolCode
	from Core.Student st inner join core.site di on st.AdministrationID = di.AdministrationID and st.DistrictCode = di.SiteCode 
	inner join Core.Site sch on st.AdministrationId = sch.AdministrationID and st.DistrictCode = sch.SuperSiteCode and st.SchoolCode = sch.SiteCode
	where st.AdministrationID=@AdministrationID and st.StateStudentID=@StateStudentID and st.StudentID<>@StudentID
GO
