USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ResetTRS]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[ResetTRS]
      @TeacherId   uniqueidentifier
     ,@WindowId    int

/*  *****************************************************************
    * Description:  Reset TRS Data for the specified TeacherId in
    *               the specified WindowId.
    *================================================================
    * Created:      4/24/2009
    * Developer:    Chad Hirmer
    *================================================================
    * Changes:
    *
    * Date:         
    * Developer:    
    * Description:  
    *****************************************************************
*/

AS

DECLARE @ListId     int
DECLARE @ListIdPrev int

SET @ListId     = 0
SET @ListIdPrev = 0

SELECT @ListId = MIN(ListId) 
FROM eWeb.TeacherStudentList 
WHERE TimeWindowId = @WindowId 
  AND TeacherId    = @TeacherId 
  AND ListId       > @ListIdPrev
WHILE @ListId > 0
  BEGIN
    DELETE FROM eWeb.StudentList WHERE ListId = @ListId
    DELETE FROM eWeb.TeacherStudentList WHERE ListId = @ListId
    SET @ListIdPrev = @ListId
    SET @ListId     = 0
    SELECT @ListId = MIN(ListId) 
    FROM eWeb.TeacherStudentList 
    WHERE TimeWindowId = @WindowId 
      AND TeacherId    = @TeacherId 
      AND ListId       > @ListIdPrev
  END
GO
