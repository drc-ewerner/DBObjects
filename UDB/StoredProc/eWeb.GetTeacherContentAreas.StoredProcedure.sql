USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTeacherContentAreas]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [eWeb].[GetTeacherContentAreas]
       @AdministrationID      int
      ,@TeacherID             int
      ,@DistrictCode          varchar(15)
      ,@SchoolCode            varchar(15)
AS

DECLARE @Table TABLE(
       [ContentArea] varchar(50)
       )
       INSERT INTO @Table
       EXECUTE [eWeb].[GetContentAreas] @AdministrationID

SELECT DISTINCT 
       st.ContentArea             AS ContentArea
      ,CAST(CASE ISNULL(tse.Value, 'Y') 
              WHEN 'Y' THEN 1 
              ELSE 0 
            END AS bit)           AS Active
FROM      Core.Teacher            ct
     JOIN Teacher.Sites           ts   ON  ct.AdministrationID    = ts.AdministrationID
                                       AND ct.TeacherID           = ts.TeacherID
     JOIN Scoring.Tests           st   ON  ct.AdministrationID    = st.AdministrationID
	 JOIN @Table                  tt   ON  st.ContentArea         = tt.ContentArea 
LEFT JOIN Teacher.SiteExtensions  tse  ON  ct.AdministrationID    = tse.AdministrationID
                                       AND ct.TeacherID           = tse.TeacherID
                                       AND st.ContentArea         = tse.Name
WHERE st.AdministrationID = @AdministrationID
  AND ct.TeacherID        = @TeacherID
  AND st.ContentArea      IS NOT NULL 
  AND st.ContentArea      NOT LIKE '$%'
  AND NOT EXISTS(SELECT * 
                 FROM Config.Extensions ext 
                 WHERE ext.AdministrationID = @AdministrationID 
                   AND ext.Category         = 'eWeb' 
                   AND ext.Name             = st.ContentArea + '.Hide' 
                   AND ext.Value            = 'Y')
  AND ts.DistrictCode     = @DistrictCode
  AND ts.SchoolCode       = @SchoolCode
GO
