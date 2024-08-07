USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAllConfigExtensions_TestSetup]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [eWeb].[GetAllConfigExtensions_TestSetup]
	@adminID int
as
								
begin
	
	Declare @project As Varchar(200)
	Declare @category As Varchar(200)
	Set @project = 'TestSetup'
	Set @category = 'eWeb'

	Select 
		e.AdministrationID,
		e.Category,
		e.Name,
		e.Value
	From [Config].[Extensions] e
	inner join [eWeb].[ConfigExtensionNames] p
	on e.Category = p.Category
	and e.Name = p.Name
	and p.eDirectProject = @project
	Where e.AdministrationID = @adminID
	And e.Category = @category
	And p.eDirectProject = @project
	Order By e.AdministrationID, e.Category, e.Name, e.Value

end
GO
