USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetAdministrationList]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [Insight].[GetAdministrationList]
	
as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

select  
	AdministrationID,
	Description
from Core.Administration
where Status!='Complete'
order by Description;
GO
