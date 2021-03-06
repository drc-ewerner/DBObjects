USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[SaveTestFormExtension]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[SaveTestFormExtension]
       @AdministrationID int, 
       @Test varchar(50), 
       @Level varchar(20),
       @Form varchar(20),
       @Name varchar(50), 
       @Value varchar(100)
AS
BEGIN 
insert into Scoring.TestFormExtensions (AdministrationID, Test, Level, Form, Name, Value)
values (@AdministrationID, @Test, @Level, @Form, @Name, @Value)

END
GO
