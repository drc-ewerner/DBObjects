USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetContentAreas]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[GetContentAreas]
@AdministrationID INT
AS
select distinct ca.ContentArea 
from Scoring.Tests t
join Scoring.ContentAreas ca on t.AdministrationID = ca.AdministrationID and t.ContentArea = ca.ContentArea
where ca.AdministrationID=@AdministrationID and ca.ContentArea is not null and ca.ContentArea not like '$%'
and ca.IsForTestSessions = 1
and not exists(select * from Config.Extensions ext where AdministrationID=@AdministrationID and Category='eWeb' and Name=ca.ContentArea + '.Hide' and Value='Y')
GO
