USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[SaveItem]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[SaveItem]
	@AdministrationID int, 
	@Test varchar(50), 
	@ItemID varchar(50), 
	@ItemType varchar(10), 
	@ItemStatus varchar(10), 
	@OnlineData XML, 
	@ItemVersion datetime	
AS
BEGIN
	update Scoring.Items set
            ItemType = @ItemType,
            ItemStatus = @ItemStatus
    where AdministrationID = @AdministrationID and
        Test = @Test and
        ItemID = @ItemID
    
    if @@rowcount = 0  
    begin          
        insert into Scoring.Items 
            (AdministrationID, Test, ItemID, 
            ItemType, ItemStatus, OnlineData)
        values
            (@AdministrationID, @Test, @ItemID,
            @ItemType, @ItemStatus, null)
    end
			
	if @ItemVersion is not null and not exists(
		select AdministrationID
		from Scoring.ItemVersions IV
		where 
			AdministrationID = @AdministrationID and
            Test = @Test and
            ItemID = @ItemID and
            ItemVersion = @ItemVersion)
            
	begin
		insert into Scoring.ItemVersions 
			(AdministrationID, Test, ItemID, ItemVersion,
			OnlineData)
		values
			(@AdministrationID, @Test, @ItemID, @ItemVersion,
			@OnlineData)
    end    
END
GO
