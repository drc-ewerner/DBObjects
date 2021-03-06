USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAllConfigExtensions]    Script Date: 1/12/2022 1:30:38 PM ******/
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
