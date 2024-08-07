USE [Alaska_udb_dev]
GO
/****** Object:  View [Scoring].[ScoringMatrix]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Scoring].[ScoringMatrix] with schemabinding as
select tfs.AdministrationID,tfs.Test,tfs.Level,tfs.Form,tfs.Score,tfsi.ItemID,tfsi.DetailID,tfsi.ScoreRule,tfsi.AttemptRule,tfsi.Multiplier,AttemptDivisor=count_big(*)
from Scoring.TestFormScores tfs
inner join Scoring.TestFormScoreItems tfsi on tfsi.AdministrationID=tfs.AdministrationID and tfsi.Test=tfs.Test and tfsi.Level=tfs.Level and tfsi.Form=tfs.Form and tfsi.Score=tfs.Score
inner join Scoring.ItemDetails id on id.AdministrationID=tfs.AdministrationID and id.Test=tfs.Test and id.ItemID=tfsi.ItemID and case when tfsi.AttemptRule='detail' then id.DetailID else tfsi.DetailID end=tfsi.DetailID
group by tfs.AdministrationID,tfs.Test,tfs.Level,tfs.Form,tfs.Score,tfsi.ItemID,tfsi.DetailID,tfsi.ScoreRule,tfsi.AttemptRule,tfsi.Multiplier;
GO
