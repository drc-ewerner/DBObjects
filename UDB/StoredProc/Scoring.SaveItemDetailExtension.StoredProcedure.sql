USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[SaveItemDetailExtension]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[SaveItemDetailExtension]
	@AdministrationID int, 
	@Test varchar(50), 
	@ItemID varchar(50),
	@DetailID varchar(20), 
	@Name varchar(50), 
	@Value varchar(300)
AS
BEGIN 
	insert into Scoring.ItemDetailExtensions 
            (AdministrationID, Test, ItemID, DetailID, Name, Value)
        values
            (@AdministrationID, @Test, @ItemID, @DetailID, @Name, @Value)
END
GO
