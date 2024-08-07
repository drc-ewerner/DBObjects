USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[DeleteScoringData]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[DeleteScoringData]
(
	@AdministrationID AS Int,
	@Test AS varchar(50) = NULL
)
AS
BEGIN

-- Test-specific data	
-- Note: Due to Cascading Referential Integrity Constraints, related data in the following tables will also be deleted if exists:
-- [Scoring].[TestMapScores], [Scoring].[TestMapRanges], [Scoring].[TestMapExtensions], [Scoring].[TestMaps], [Scoring].[Standards], 
-- [Scoring].[Accommodations], [Scoring].[ItemAccommodations], [Scoring].[TestScoreExtensions], [Scoring].[TestScores], 
-- [Scoring].[TestLevels], [Scoring].[TestForms], [Scoring].[TestFormExtensions], [Scoring].[TestAccommodationForms],
-- [Scoring].[TestFormParts], [Scoring].[TestFormItems], [Scoring].[TestFormScores], [Scoring].[TestFormScoreItems],
-- [Scoring].[TestFormScoreOptions], [Scoring].[TestFormScorePerformanceLevels], [Scoring].[TestFormScorePsychometrics],
-- [Scoring].[TestFormVersions], [Scoring].[TestFormItemVersions]

DELETE [Scoring].[Tests]
WHERE [AdministrationID] = @AdministrationID
	AND [Test] = ISNULL(@Test, [Test])
	
-- Item Data	
-- Note: Due to Cascading Referential Integrity Constraints, related data in the following tables will also be deleted if exists:
-- [Scoring].[ItemDetailPsychometrics], [Scoring].[ItemDetailExtensions], [Scoring].[ItemDetails], [Scoring].[ItemAccommodations],
-- [Scoring].[ItemExtensions], [Scoring].[TestFormItems], [Scoring].[ItemResponseChangeOrder], [Scoring].[TestFormScoreItems],
-- [Scoring].[ItemVersions], , [Scoring].[TestFormItemVersions]

DELETE [Scoring].[Items]
WHERE [AdministrationID] = @AdministrationID
	AND [Test] = ISNULL(@Test, [Test])
	
END
GO
