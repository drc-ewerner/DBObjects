USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[SaveItemDetail]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Scoring].[SaveItemDetail]
	@AdministrationID int, 
	@Test varchar(50), 
	@ItemID varchar(50), 
	@DetailID varchar(20), 
	@DetailPosition int, 
	@CorrectResponse varchar(10), 
	@MaxScore decimal (10,5),
	@ScoreRule varchar(50),
	@DetailType varchar(50),
	@Logging bit = 0
AS

BEGIN

		declare @OriginalCorrectResponse varchar(10) = ''

		if @Logging = 1
		begin
			Select @OriginalCorrectResponse = (select top 1 isnull(CorrectResponse, '') as CorrectResponse 
			from Scoring.Items i 
			inner join Scoring.ItemDetails id on i.AdministrationID = id.AdministrationID
			and i.Test = id.Test and i.ItemID = id.itemid
			where i.AdministrationID=@AdministrationID and i.Test=@Test and i.ItemID=@ItemID 
			and DetailID=0 and i.ItemType = 'MC')

   		    if @OriginalCorrectResponse IS NULL or (@OriginalCorrectResponse <> @CorrectResponse)
				begin	
					insert into scoring.ItemScoringRulesChangeLog 
					(AdministrationID, Test, ItemID, ScoringRulesXML, Action, LogDate)
					values (@AdministrationID, @Test, @ItemID, '<CorrectResponse>' + @CorrectResponse + '</CorrectResponse>'
					, case when @OriginalCorrectResponse IS NULL then 'Create' else 'Update' end, GETDATE())					
				end	
		end

		update I set
            CorrectResponse = @CorrectResponse,
            MaxScore = @MaxScore,
			DetailType = @DetailType 
        from Scoring.ItemDetails I
        where I.AdministrationID = @AdministrationID and
            I.Test = @Test and
            I.ItemID = @ItemID and
            I.DetailID = @DetailID
        if @@rowcount = 0  
        begin          
            insert into Scoring.ItemDetails 
                (AdministrationID, Test, ItemID, DetailID,
                DetailPosition, CorrectResponse, MaxScore, ScoreRule, DetailType)
            values
                (@AdministrationID, @Test, @ItemID, @DetailID,
                @DetailPosition, @CorrectResponse, @MaxScore, @ScoreRule, @DetailType)
        end

 END
GO
