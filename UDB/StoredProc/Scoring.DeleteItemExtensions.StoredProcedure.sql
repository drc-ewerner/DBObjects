USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[DeleteItemExtensions]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[DeleteItemExtensions]
	@AdministrationID int, 
	@Test varchar(50), 
	@ItemID varchar(50)
AS
BEGIN 
	delete from Scoring.ItemExtensions
    where AdministrationID = @AdministrationID and
            Test = @Test and
            ItemID = @ItemID 
END
GO
