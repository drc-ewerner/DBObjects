USE [Alaska_udb_dev]
GO
/****** Object:  View [eWeb].[Grades]    Script Date: 1/12/2022 1:31:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [eWeb].[Grades] as 
	select grade,administrationID from core.student group by grade,administrationId
GO
