USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAdministrationsWithScoring]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [eWeb].[GetAdministrationsWithScoring]
as

Select distinct administrationid from TestEvent.TestScores
GO
