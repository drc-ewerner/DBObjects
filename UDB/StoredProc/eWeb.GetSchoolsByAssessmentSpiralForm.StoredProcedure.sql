USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetSchoolsByAssessmentSpiralForm]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [eWeb].[GetSchoolsByAssessmentSpiralForm]
@AdministrationID int,
@Test varchar(50),
@Level varchar(20),
@FormName varchar(100)
AS
Begin

	Select  
	se.DistrictCode, 
	se.SchoolCode,
	HasStartedTickets = 
		case 
			when sum( case when tkt.DocumentID is null then 0 else 1 end) > 0 then cast( 1 as Bit)
			else cast( 0 as Bit)
		end
	From [Site].Extensions se 
	Left Join Core.TestSession ts
		On ts.AdministrationID = se.AdministrationID
			And ts.DistrictCode = se.DistrictCode
			And ts.SchoolCode = se.SchoolCode
			And se.Name = ts.Test +'.' +ts.Level + '.FORMNAME' 
	Left Join TestSession.Links lnk 
		On lnk.AdministrationID = ts.AdministrationID
			And lnk.TestSessionID = ts.TestSessionID
	Left Join document.TestTicketView tkt 
		On tkt.AdministrationID = lnk.AdministrationID
			And tkt.DocumentID = lnk.DocumentID
			And tkt.Status <> 'Not Started'
	Where se.AdministrationID = @AdministrationID
	And se.Category = 'Spiral'
	And se.Name = @Test +'.' +@Level + '.FORMNAME' 
	And se.[Value] = @FormName
	Group By se.DistrictCode, se.SchoolCode

End
GO
