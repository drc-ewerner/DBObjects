USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[SaveItemExtension]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Scoring].[SaveItemExtension]
	@AdministrationID int, 
	@Test varchar(50), 
	@ItemID varchar(50), 
	@Name varchar(50), 
	@Value varchar(700)
AS
BEGIN 
	insert into Scoring.ItemExtensions 
            (AdministrationID, Test, ItemID, Name, Value)
        values
            (@AdministrationID, @Test, @ItemID, @Name, @Value)
END
GO
