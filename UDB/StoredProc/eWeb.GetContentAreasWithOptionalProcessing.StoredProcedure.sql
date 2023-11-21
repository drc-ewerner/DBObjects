USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetContentAreasWithOptionalProcessing]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [eWeb].[GetContentAreasWithOptionalProcessing]
      @AdministrationID            int
AS
BEGIN
	select distinct ca.ContentArea, tl.OptionalProcessing
	from Scoring.Tests t
	join Scoring.ContentAreas ca on t.AdministrationID = ca.AdministrationID and t.ContentArea = ca.ContentArea
	join Scoring.TestLevels tl ON tl.AdministrationID = t.AdministrationID AND tl.Test = t.Test
	where ca.AdministrationID=@AdministrationID and ca.ContentArea is not null and ca.ContentArea not like '$%'
	and ca.IsForTestSessions = 1
	and not exists(select * from Config.Extensions ext where AdministrationID=@AdministrationID and Category='eWeb' and Name=ca.ContentArea + '.Hide' and Value='Y')
END
GO
