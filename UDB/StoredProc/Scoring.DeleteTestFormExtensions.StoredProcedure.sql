USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[DeleteTestFormExtensions]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[DeleteTestFormExtensions]
       @AdministrationID int, 
       @Test varchar(50), 
       @Level varchar(20),
       @Form varchar(20)
AS
BEGIN 
    delete from Scoring.TestFormExtensions
    where AdministrationID = @AdministrationID and
            Test = @Test and
            Level = @Level and
            Form = @Form  

END
GO
