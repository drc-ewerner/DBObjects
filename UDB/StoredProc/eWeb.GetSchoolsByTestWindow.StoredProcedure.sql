USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetSchoolsByTestWindow]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetSchoolsByTestWindow]
@AdministrationID INT,
@TestWindow varchar(20)
AS
Begin
	SELECT DistrictCode, SchoolCode
	FROM [Site].TestWindows
	WHERE AdministrationID = @AdministrationID
	AND TestWindow = @TestWindow
	AND SchoolCode <> ''
End
GO
