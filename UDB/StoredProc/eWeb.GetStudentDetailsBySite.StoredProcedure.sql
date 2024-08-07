USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentDetailsBySite]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetStudentDetailsBySite] 
	@AdministrationID integer,
	@DistrictCode varchar(20),
	@SchoolCode varchar(20),
	@NewAdministrationID integer
AS
BEGIN

	/*
	This sproc is used to return the student details and extension details for a given site from an administration
  	to a new administration.
  	Only students who are qualified with the following conditions can be copied to the new administration
  		1. The student must not exist for any site in the new administation
  		2. The district and school which the student belongs to must exist in the new administration
 	*/
	
	Select @SchoolCode = nullif( @SchoolCode, '')
	
	Select 
	s.*
	,ExtAdministrationID = se.AdministrationID
	,ExtStudentID = se.StudentID
	,ExtCategory = se.Category
	,ExtName = se.Name
	,ExtValue =se.Value
	From Core.Student s
	Inner Join Core.Site ds on ds.AdministrationID = @NewAdministrationID  and ds.SiteCode = s.DistrictCode and ds.SiteType='District'
	Inner Join Core.Site ss on ss.AdministrationID = @NewAdministrationID  and ss.SuperSiteCode = s.DistrictCode and ss.SiteCode = s.SchoolCode and ss.SiteType='School'
	Left Join Student.Extensions se on se.AdministrationID = s.AdministrationID and se.StudentID = s.StudentID
	Left Join 
	( Select Distinct StateStudentID 
	  From Core.Student 
	  Where AdministrationID = @NewAdministrationID) 
	  As ns on ns.StateStudentID = s.StateStudentID
	Where s.AdministrationID = @AdministrationID
	and s.DistrictCode = @DistrictCode
	and s.SchoolCode = coalesce(@SchoolCode,s.SchoolCode)
	and ns.StateStudentID is null
END
GO
