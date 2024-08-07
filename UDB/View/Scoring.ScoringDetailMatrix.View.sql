USE [Alaska_udb_dev]
GO
/****** Object:  View [Scoring].[ScoringDetailMatrix]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Scoring].[ScoringDetailMatrix] with schemabinding as 
select tfs.AdministrationID,tfs.Test,tfs.Level,tfs.Form,tfs.Score,tfsi.ItemID,tfsi.DetailID,tfi.Position,id.DetailPosition,i.ItemType,id.DetailType
from Scoring.TestFormScores tfs
inner join Scoring.TestFormScoreItems tfsi on tfsi.AdministrationID=tfs.AdministrationID and tfsi.Test=tfs.Test and tfsi.Level=tfs.Level and tfsi.Form=tfs.Form and tfsi.Score=tfs.Score
inner join Scoring.TestFormItems tfi on tfi.AdministrationID=tfs.AdministrationID and tfi.Test=tfs.Test and tfi.Level=tfs.Level and tfi.Form=tfs.Form and tfi.ItemID=tfsi.ItemID
inner join Scoring.Items i on i.AdministrationID=tfs.AdministrationID and i.Test=tfs.Test and i.ItemID=tfsi.ItemID
inner join Scoring.ItemDetails id on id.AdministrationID=tfs.AdministrationID and id.Test=tfs.Test and id.ItemID=tfsi.ItemID and id.DetailID=tfsi.DetailID
GO
