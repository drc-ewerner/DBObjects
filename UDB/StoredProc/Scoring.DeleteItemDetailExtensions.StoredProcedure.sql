USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[DeleteItemDetailExtensions]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[DeleteItemDetailExtensions]
	@AdministrationID int, 
	@Test varchar(50), 
	@ItemID varchar(50),
	@DetailID varchar(20)
AS
BEGIN 
	delete from Scoring.ItemDetailExtensions
    where AdministrationID = @AdministrationID and
            Test = @Test and
            ItemID = @ItemID and
            DetailID = @DetailID 
END
GO
