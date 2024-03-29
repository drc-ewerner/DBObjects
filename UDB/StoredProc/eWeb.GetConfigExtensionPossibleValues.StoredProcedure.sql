USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetConfigExtensionPossibleValues]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[GetConfigExtensionPossibleValues]
AS

select 
	A.[NamesID], 
	A.[eDirectProject], 
	A.[ControlName],
	A.[Category], 
	A.[Name], 
	B.[ValuesID], 
	B.[PossibleValue] 
from eWeb.ConfigExtensionNames A
left outer join eWeb.ConfigExtensionValues B
on A.NamesID = B.NamesID
Order By A.SortOrder, B.SortOrder
GO
