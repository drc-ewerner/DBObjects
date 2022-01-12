USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UnassignSchoolByAssessmentSpiralForm]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[UnassignSchoolByAssessmentSpiralForm]
@AdministrationID int,
@DistrictCode varchar(15),
@SchoolCode varchar(15),
@Test varchar(50),
@Level varchar(20),
@FormName varchar(100)
AS
Begin

	Delete From [Site].Extensions
	Where AdministrationID = @AdministrationID
	And DistrictCode = @DistrictCode
	And SchoolCode = @SchoolCode
	And Category = 'Spiral'
	And Name = @Test +'.' +@Level + '.FORMNAME' 
	And [Value] = @FormName
	
End
GO
