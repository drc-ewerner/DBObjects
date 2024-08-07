USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetConfigExtensionPossibleValues]    Script Date: 7/2/2024 9:21:54 AM ******/
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
