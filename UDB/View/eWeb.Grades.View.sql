USE [Alaska_udb_dev]
GO
/****** Object:  View [eWeb].[Grades]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [eWeb].[Grades] as 
	select grade,administrationID from core.student group by grade,administrationId
GO
