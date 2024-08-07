USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetAdministrationDetails]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [Insight].[GetAdministrationDetails]
as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

select a.AdministrationID,AdministrationName,[Year],Season,[Description],LongDescription,
	cast(case when isnull(Incl.Value,'N')='Y' then 1 else 0 end as bit) IncludeIn,
	cast(case when isnull(Audio.Value,'N')='Y' then 1 else 0 end as bit) Audio,
	cast(case when isnull(Video.Value,'N')='Y' then 1 else 0 end as bit) Video
from Core.Administration a
outer apply (select Value from Config.Extensions e where e.AdministrationID=a.AdministrationID and e.Category='Manifest' 
	and e.Name='IncludeIn') Incl
outer apply (select Value from Config.Extensions e where e.AdministrationID=a.AdministrationID and e.Category='Manifest' 
	and e.Name='Audio') Audio
outer apply (select Value from Config.Extensions e where e.AdministrationID=a.AdministrationID and e.Category='Manifest' 
	and e.Name='Video') Video
;
GO
