USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAdministrationsWithScoring]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [eWeb].[GetAdministrationsWithScoring]
as

Select distinct administrationid from TestEvent.TestScores
GO
