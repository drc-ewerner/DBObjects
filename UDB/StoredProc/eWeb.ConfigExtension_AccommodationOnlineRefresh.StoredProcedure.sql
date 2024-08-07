USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ConfigExtension_AccommodationOnlineRefresh]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[ConfigExtension_AccommodationOnlineRefresh]
	@AdminID As Integer
AS


Delete From [Config].[Extensions]
Where AdministrationID = @AdminID
and Category = 'Accommodation.Online'



Insert Into [Config].[Extensions] (AdministrationID, Category, Name, Value, Usage)
Select distinct V.[AdministrationID], 'Accommodation.Online', V.[Category] + '.' + V.[Name], V.[Value], 'Test Setup'
From [XRef].[StudentExtensionValues] V
Inner Join [Scoring].[Tests] ST
	ON V.AdministrationID = ST.AdministrationID
	AND V.Category = ST.ContentArea
Where V.AdministrationID = @AdminID
AND V.Name like 'Online%'
AND V.DisplayValue like '%Y%'
GO
