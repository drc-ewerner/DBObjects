USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetMapConfigurations]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Object:  StoredProcedure [eWeb].[GetMapConfigurations]    Script Date: 09/10/2010 10:35:12 ******/
CREATE PROCEDURE [eWeb].[GetMapConfigurations]

@AdministrationID INT 

AS

BEGIN
	SELECT
		tm.[AdministrationID],
		t.ContentArea,
		tm.[Test],
		tm.[Map],
		tm.[Description]
	FROM
		[Scoring].[TestMaps] tm
--validate that the test + level specified actually exists
		INNER JOIN Scoring.TestMapExtensions ext ON ext.AdministrationID=tm.AdministrationID and ext.Test=tm.Test and ext.Map=tm.Map and ext.Name='Level'
		INNER JOIN Scoring.TestLevels tl ON tm.AdministrationID=tl.AdministrationID and tm.Test=tl.Test and ext.Value=tl.Level
        INNER JOIN Scoring.Tests t ON tl.AdministrationID=t.AdministrationID AND tl.Test = t.Test
	WHERE
		tm.[AdministrationID] = @AdministrationID  
		
END
GO
