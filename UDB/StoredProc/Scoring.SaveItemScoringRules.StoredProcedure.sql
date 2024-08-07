USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[SaveItemScoringRules]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[SaveItemScoringRules]
	@AdministrationID int, 
	@Test varchar(50), 
	@ItemID varchar(50), 
	@ScoringRulesXML XML, 
	@LastModifiedDate datetime
AS

BEGIN
	declare @Action varchar(10)
	declare @OriginalLastModifiedDate dateTime
	
	Select @OriginalLastModifiedDate = (select LastModifiedDate 
	from Scoring.ItemScoringRules 
	where AdministrationID=@AdministrationID and Test=@Test and ItemID=@ItemID)	

	if @OriginalLastModifiedDate is null or (@OriginalLastModifiedDate < @LastModifiedDate)
	begin
		update SR set
            ScoringRulesXML = @ScoringRulesXML,
            LastModifiedDate = @LastModifiedDate			
        from Scoring.ItemScoringRules SR
        where SR.AdministrationID = @AdministrationID and
            SR.Test = @Test and
            SR.ItemID = @ItemID 
        if @@rowcount = 0  
        begin          
            insert into Scoring.ItemScoringRules
                (AdministrationID, Test, ItemID, ScoringRulesXML, LastModifiedDate)
            values
                (@AdministrationID, @Test, @ItemID, @ScoringRulesXML, @LastModifiedDate)
			set @Action = 'Create'
        end
		else
		begin
			set @Action = 'Update'
		end

		insert into scoring.ItemScoringRulesChangeLog
		(AdministrationID, Test, ItemID, ScoringRulesXML, Action, LogDate)
		values
		(@AdministrationID, @Test, @ItemID, @ScoringRulesXML,@Action, GETDATE())
	end

 END
GO
