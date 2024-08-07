USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateTeacherContentArea]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[UpdateTeacherContentArea]
       @AdministrationID      int
      ,@TeacherID             int
      ,@DistrictCode          varchar(15)
      ,@SchoolCode            varchar(15)
      ,@ContentArea           varchar(50)
      ,@Active                bit
AS

IF @Active = 0
  BEGIN
    INSERT INTO Teacher.SiteExtensions (
           AdministrationID
          ,TeacherID
          ,DistrictCode
          ,SchoolCode
          ,Name
          ,Value )
    SELECT @AdministrationID
          ,@TeacherID
          ,@DistrictCode
          ,@SchoolCode
          ,@ContentArea
          ,'N'
    WHERE NOT EXISTS (SELECT 1
                      FROM Teacher.SiteExtensions
                      WHERE AdministrationID = @AdministrationID
                        AND TeacherID        = @TeacherID
                        AND DistrictCode     = @DistrictCode
                        AND SchoolCode       = @SchoolCode
                        AND Name             = @ContentArea)
  END
ELSE
  BEGIN
    DELETE FROM Teacher.SiteExtensions
    WHERE AdministrationID = @AdministrationID
      AND TeacherID        = @TeacherID
      AND DistrictCode     = @DistrictCode
      AND SchoolCode       = @SchoolCode
      AND Name             = @ContentArea
  END
GO
