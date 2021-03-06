USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetAdministrationList]    Script Date: 1/12/2022 1:30:39 PM ******/
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
