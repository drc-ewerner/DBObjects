USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[PurgeItemExtensions]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Scoring].[PurgeItemExtensions]
	@AdministrationID int, 
	@Test varchar(50), 
	@ItemID varchar(50)
AS
BEGIN 
	delete
        from Scoring.ItemExtensions
        where AdministrationID = @AdministrationID and
            Test = @Test and
            ItemID = @ItemID and
            Name IN (
                    'ReportingFlags',
                    'OptionCount',
                    'AdaptGradeLow',
                    'AdaptGradeHigh',
                    'UsagePriority',
                    'IRT_A',
                    'IRT_B',
                    'IRT_C',
                    'PointBiserial',
                    'Calculator',
                    'MinScorePoints',
                    'UsageID',
                    'StandardSequence',
                    'StandardSet',
                    'StandardFormatted',
                    'Goal1',
                    'Goal2',
                    'Goal3',
                    'Goal4',
                    'Goal5',
                    'StandardDescription',
                    'Domain',
                    'StandardRank',
                    'SubUse',
                    'SubPoints',
                    'Weight',
                    'SourceItemID', 
                    'SourceBatch', 
                    'SourceItemType', 
                    'SourceItemSubType', 
                    'Steps', 
                    'Source', 
                    'ScoreLevel')
END
GO
