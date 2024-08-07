USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentNumberBySite]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[GetStudentNumberBySite] 
	@AdministrationID integer,
	@DistrictCode varchar(15),
	@SchoolCode varchar(15),
	@NewAdministrationID integer
AS
BEGIN
	/*
	This sproc is used to indicate how many students is available for a given site in an administration
  	and how many students can be copied to a new administration.
  	Only students who are qualified with the following conditions can be copied to the new administration
  		1. The student must not exist for any site in the new administation
  		2. The district and school which the student belongs to must exist in the new administration
 	*/
	
	Select @SchoolCode = nullif( @SchoolCode, '')
	
	Select 
	TotalStudents = count(*)
	,NewStudents = sum( case when ns.StateStudentID is null and ds.SiteCode is not null and ss.SiteCode is not null then 1 else 0 end)
	From Core.Student s
	Left Join Core.Site ds on ds.AdministrationID = @NewAdministrationID  and ds.SiteCode = s.DistrictCode and ds.SiteType='District'
	Left Join Core.Site ss on ss.AdministrationID = @NewAdministrationID  and ss.SuperSiteCode = s.DistrictCode  and ss.SiteCode = s.SchoolCode  and ss.SiteType='School'
	Left Join 
	( Select Distinct StateStudentID 
	  From Core.Student 
	  Where AdministrationID = @NewAdministrationID) 
	  As ns  on ns.StateStudentID = s.StateStudentID
	Where s.AdministrationID = @AdministrationID
	and s.DistrictCode = @DistrictCode
	and s.SchoolCode = coalesce(@SchoolCode,s.SchoolCode)
	
END
GO
