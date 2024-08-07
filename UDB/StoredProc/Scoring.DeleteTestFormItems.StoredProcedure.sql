USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[DeleteTestFormItems]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[DeleteTestFormItems]
	@AdministrationID int, 
	@Test varchar(50), 
	@Level varchar(20),
	@Form varchar(20)
AS
BEGIN 
	delete from Scoring.TestFormItems
    where AdministrationID = @AdministrationID and
            Test = @Test and
            Level = @Level and
            Form = @Form 
END
GO
