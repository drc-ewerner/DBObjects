USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetSchoolsHaveStartedTicketsByDistrict]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [eWeb].[GetSchoolsHaveStartedTicketsByDistrict]
@AdministrationID INT,
@DistrictCode varchar(15),
@Test varchar(50),
@Level varchar(20)
AS
Begin
	Select Distinct ts.DistrictCode, ts.SchoolCode
	From Core.TestSession ts
	Inner Join TestSession.Links lnk
		On lnk.AdministrationID = ts.AdministrationID
			And lnk.TestSessionID = ts.TestSessionID
	Inner Join document.TestTicketView tkt 
		On tkt.AdministrationID = lnk.AdministrationID
			And tkt.DocumentID = lnk.DocumentID
			And tkt.Status <> 'Not Started'
	Where ts.AdministrationID = @AdministrationID
	And ts.DistrictCode = @DistrictCode
	And ts.Test = @Test
	And ts.Level = @Level
End
GO
