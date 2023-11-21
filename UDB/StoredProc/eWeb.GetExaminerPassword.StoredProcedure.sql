USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetExaminerPassword]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetExaminerPassword]
@AdministrationID INT, @DistrictCode varchar(15), @SchoolCode varchar(15)
AS
select [ExaminerPassword]=Value from [eWeb].[SiteExtensions] where AdministrationID=@AdministrationID and DistrictCode=@DistrictCode and SchoolCode=@SchoolCode and Name='Examiner Password'
GO
