USE [Alaska_udb_dev]
GO
/****** Object:  View [eWeb].[Grades]    Script Date: 11/21/2023 8:54:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [eWeb].[Grades] as 
	select grade,administrationID from core.student group by grade,administrationId
GO
