USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetDistrictsByTestWindow]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetDistrictsByTestWindow]
@AdministrationID INT,
@TestWindow varchar(20)
AS
Begin
	SELECT DistrictCode
	FROM [Site].[TestWindows]
	WHERE AdministrationID = @AdministrationID
	AND TestWindow = @TestWindow
	AND SchoolCode = ''
End
GO
