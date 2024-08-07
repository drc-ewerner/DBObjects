USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestedContentAreas]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [eWeb].[GetTestedContentAreas]
@AdministrationID INT,
@DistrictCode varchar(15),
@SchoolCode varchar(15)
AS
Select Distinct t.ContentArea 
From Scoring.Tests t
Inner Join Core.TestSession s On s.AdministrationID = t.AdministrationID And s.Test = t.Test
Where s.AdministrationID=@AdministrationID 
And s.DistrictCode = @DistrictCode
And s.SchoolCode = @SchoolCode
And ContentArea is not null 
And ContentArea not like '$%'
And not exists(select * from Config.Extensions ext where AdministrationID=@AdministrationID and Category='eWeb' and Name=ContentArea + '.Hide' and Value='Y')
GO
