USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAssessmentsByStudent]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetAssessmentsByStudent] (
       @AdministrationID int
      ,@StudentId        int
      )
AS
/* 10/04/2011 - Version 1.0 - */

SELECT DISTINCT 
       st.ContentArea
      ,m.Test
      ,te.Level
      ,m.Map
      ,m.Description 
FROM       Core.Document             d 
INNER JOIN Core.TestEvent            te ON   te.AdministrationID = d.AdministrationID 
                                        AND  te.DocumentID       = d.DocumentID 
INNER JOIN Scoring.TestMapExtensions mx ON   mx.AdministrationID = d.AdministrationID 
                                        AND  mx.Test             = te.Test 
                                        AND  mx.Name             = 'Level' 
                                        AND  mx.Value            = te.Level 
INNER JOIN Scoring.TestMaps          m  ON   m.AdministrationID  = d.AdministrationID 
                                        AND  m.Test              = te.Test 
                                        AND  m.Map               = mx.Map 
INNER JOIN Scoring.Tests             st ON   st.AdministrationID = d.AdministrationID 
                                        AND  st.Test             = te.Test 
WHERE d.AdministrationID = @AdministrationID 
  AND d.StudentID        = @StudentId
GO
