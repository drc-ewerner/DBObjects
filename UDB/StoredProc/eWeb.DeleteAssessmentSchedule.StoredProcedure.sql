USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteAssessmentSchedule]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[DeleteAssessmentSchedule]
@AdministrationID INT,
@TestWindow varchar(20),
@Test varchar(50),
@Level varchar(20),
@Mode varchar(50)
AS
Begin

DELETE FROM [Admin].[AssessmentSchedule]
 WHERE AdministrationID=@AdministrationID  
 and TestWindow=@TestWindow
 and Test=@Test
 and Level=@Level
 and Mode=@Mode
 
End
GO
