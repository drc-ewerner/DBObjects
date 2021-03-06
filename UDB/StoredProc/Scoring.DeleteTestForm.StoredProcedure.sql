USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[DeleteTestForm]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[DeleteTestForm]
	@AdministrationID int, 
	@Test varchar(50), 
	@Level varchar(20),
	@Form varchar(20)
AS
BEGIN 
	delete from Scoring.TestForms
    where AdministrationID = @AdministrationID and
            Test = @Test and
            Level = @Level and
            Form = @Form 
END
GO
