USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAdministrationsWithScoring]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [eWeb].[GetAdministrationsWithScoring]
as

Select distinct administrationid from TestEvent.TestScores
GO
