USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAllConfigExtensions]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [eWeb].[GetAllConfigExtensions]
	@adminID int
as
								
begin
	
	Select 
		AdministrationID,
		Category,
		Name,
		Value
	From [Config].[Extensions]
	Where AdministrationID = @adminID
	And Category = 'eWeb'
	Order By AdministrationID, Category, Name, Value

end
GO
