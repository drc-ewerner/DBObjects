USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAllGradesWithoutIsNotOnlineTestingFlag]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [eWeb].[GetAllGradesWithoutIsNotOnlineTestingFlag]
	@adminID int
as
Declare @isDescriptionMode bit
select @isDescriptionMode=case when eWeb.GetConfigExtensionValue(@adminID,'eWeb','ConfigUI.GradeDropDownDescriptionMode','N')='Y' then 1 else 0 end
									
begin
	Select distinct 
		Grade, 
		Case When @isDescriptionMode = 1 Then ISNULL(NULLIF(LTRIM(RTRIM(Description)), ''), Grade)
		Else Grade
		End as Text,
		 ISNULL(DisplayOrder, 0) as DisplayOrder
	From Xref.Grades
	Where [AdministrationID] = @adminID
	And Grade Not In ('--', '**', '', ' ')
	And (DisplayOrder > 0 Or DisplayOrder is null)
	Order By ISNULL(DisplayOrder, 0), Grade 

end
GO
