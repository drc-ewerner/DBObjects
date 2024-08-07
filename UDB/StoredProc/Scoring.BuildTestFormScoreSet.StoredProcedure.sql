USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[BuildTestFormScoreSet]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Scoring].[BuildTestFormScoreSet]
	@AdministrationID int, 
	@Test varchar(50), 
	@Level varchar(20), 
	@Form varchar(20), 
	@Score varchar(50), 
	@Description varchar(1000), 
	@DiagnosticCategoryID varchar(100), 
	@ItemType varchar(10),
	@ItemStatus varchar(10),
	@ItemIDs XML
AS
BEGIN
	-- TestScore
	If not exists(select AdministrationID 
				from Scoring.TestScores 
				where AdministrationID = @AdministrationID and 
					Test = @Test and
					Score = @Score)
	begin
		insert Scoring.TestScores 
			(AdministrationID, Test, Score, Description) 
		values 
			(@AdministrationID, @Test, @Score, @Description);
		
		if Len(@DiagnosticCategoryID) > 0
		insert 	Scoring.TestScoreExtensions
			(AdministrationID, Test, Score, Name, Value) 
		values 
			(@AdministrationID, @Test, @Score, 'DiagnosticCategoryID', @DiagnosticCategoryID);		
	end

	-- TestFormScore
	If not exists(select AdministrationID 
				from Scoring.TestFormScores 
				where AdministrationID = @AdministrationID and 
					Test = @Test and
					Level = @Level and
					Form = @Form and
					Score = @Score)
	begin
		insert Scoring.TestFormScores 
			(AdministrationID, Test, Level, Form, Score, 
			MaxRawScore, MaxScaleScore, MaxItemsAttempted, AttemptThreshold, RawScoreThreshold) 
		values 
			(@AdministrationID, @Test, @Level, @Form, @Score,
			0.0, 0.0, 0, 0, 0.0);
	end

	-- TestFormScoreItems	
	insert into Scoring.TestFormScoreItems 
			(AdministrationID, Test, Level, Form, Score, ItemID, DetailID,
			ScoreRule, AttemptRule, Multiplier)
		select 
			@AdministrationID, @Test, @Level, @Form, @Score, 
			i.ItemID, d.DetailID, 
			'', 'detail',
			case when isnull(ide.Value, '') = '' then cast(1.0 as decimal(10,5))
				 else cast(ide.Value as decimal(10,5))
			end	
		from Scoring.TestFormItems tfi
		inner join Scoring.Items i on
			i.AdministrationID = tfi.AdministrationID and 
			i.Test = tfi.Test and 
			i.ItemID = tfi.ItemID and
			(isnull(@ItemType, '') = '' or i.ItemType = @ItemType) and 
			(isnull(@ItemStatus, '') = '' or i.ItemStatus = @ItemStatus) and
			(@ItemIDs is NULL or i.itemID in
				(
				select item.node.value('@itemid', 'varchar(50)') 
				from @ItemIDs.nodes('/items/item') item(node)
				)
			)			
		inner join Scoring.ItemDetails d on
			d.AdministrationID = tfi.AdministrationID and 
			d.Test = tfi.Test and 
			d.ItemID = tfi.ItemID and
			d.MaxScore > 0.0 		-- this is to exclude CR ItemParts
		-- check for existing 
		left join Scoring.TestFormScoreItems tfsi on
			tfsi.AdministrationID = tfi.AdministrationID and 
			tfsi.Test = tfi.Test and 
			tfsi.Level = tfi.Level and 
			tfsi.Form = tfi.Form and 
			tfsi.Score = @Score and 
			tfsi.ItemID = tfi.ItemID and 
			tfsi.DetailID = d.DetailID
		left join Scoring.ItemDetailExtensions ide on
			ide.AdministrationID = tfi.AdministrationID and 
			ide.Test = tfi.Test and 
			ide.ItemID = tfi.ItemID and
			ide.DetailID = d.DetailID and
			Name = 'Weight'
		where 
			tfi.AdministrationID = @AdministrationID and 
			tfi.Test = @Test and 
			tfi.Level = @Level and 
			tfi.Form = @Form and 			
			-- only insert if not already exists 
			tfsi.AdministrationID is null
		;		
			
		-- Update TestFormScores: MaxScore and MaxItemsAttempted
		with scores as (
		select tfsi.AdministrationID, tfsi.Test, tfsi.Level, tfsi.Form, tfsi.Score,
				MaxScore = sum(tfsi.Multiplier*D.MaxScore),
				MaxItems = count(distinct d.ItemId)
		from Scoring.TestFormScoreItems tfsi 
		inner join Scoring.ItemDetails d on   
			d.AdministrationID = tfsi.AdministrationID AND
			d.Test = tfsi.Test AND
			d.ItemID = tfsi.ItemID AND
			d.DetailID = tfsi.DetailID 
		where 
			tfsi.AdministrationID = @AdministrationID and 
			tfsi.Test = @Test and 
			tfsi.Level = @Level and 
			tfsi.Form = @Form and 			
			tfsi.Score = @Score 
		group by tfsi.AdministrationID, tfsi.Test, tfsi.Level, tfsi.Form, tfsi.Score
		)
		update tfs set 
				MaxRawScore = s.MaxScore,
				MaxItemsAttempted = s.MaxItems
		from Scoring.TestFormScores tfs
		inner join scores s ON 
				tfs.AdministrationID = s.AdministrationID and 
				tfs.Test = s.Test and 
				tfs.Level = s.Level and 
				tfs.Form = s.Form and 
				tfs.Score = s.Score

END
GO
