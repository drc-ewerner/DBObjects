USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[AssignSchoolByAssessmentSpiralForm]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[AssignSchoolByAssessmentSpiralForm]
@AdministrationID int,
@DistrictCode varchar(15),
@SchoolCode varchar(15),
@Test varchar(50),
@Level varchar(20),
@FormName varchar(100)
AS
Begin

	If Not Exists
	(
		Select 1 From [Site].Extensions
		Where AdministrationID = @AdministrationID
		And DistrictCode = @DistrictCode
		And SchoolCode = @SchoolCode
		And Category = 'Spiral'
		And Name = @Test +'.' +@Level + '.FORMNAME' 
		And [Value] = @FormName

	)
		INSERT INTO [Site].[Extensions]
           	([AdministrationID]
           	,[DistrictCode]
           	,[SchoolCode]
           	,[Category]
           	,[Name]
           	,[Value])
		VALUES
           	(@AdministrationID
           	,@DistrictCode
           	,@SchoolCode
           	,'Spiral'
           	,@Test +'.' +@Level + '.FORMNAME' 
           	,@FormName)

End
GO
