USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetGrades]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [eWeb].[GetGrades] 
	@adminID int
WITH RECOMPILE
as
									
begin
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	Declare @isDescriptionMode bit
	select @isDescriptionMode=case when eWeb.GetConfigExtensionValue(@adminID,'eWeb','ConfigUI.GradeDropDownDescriptionMode','N')='Y' then 1 else 0 end

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
