USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[IsSchoolPublic]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [eWeb].[IsSchoolPublic]
	@AdministrationID int,
	@DistictCode varchar(15),
	@SchoolCode varchar(15)
As

Declare @found bit

If Exists(Select * from Core.Site where 
			AdministrationID=@AdministrationID and
			SiteCode=@SchoolCode and 
			SuperSiteCode=@DistictCode and 
			SiteSubType='N=Non Public (Private) School'
			)
	select @found=0
else
	Select @found=1
	
	
return @found
GO
