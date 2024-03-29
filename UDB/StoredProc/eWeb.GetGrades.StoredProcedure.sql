USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetGrades]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [eWeb].[GetGrades] 
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
	and isnull(IsNotOnlineTesting, 'F') <> 'T'
	Order By ISNULL(DisplayOrder, 0), Grade 
	
	--select distinct Grade from Xref.Grades
	--order by grade asc


end
GO
