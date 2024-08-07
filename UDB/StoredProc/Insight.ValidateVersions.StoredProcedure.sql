USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[ValidateVersions]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [Insight].[ValidateVersions]
	@AdministrationID int,
	@ClientVersion varchar(20),
    @LCSVersion varchar(20),
    @ClientOS varchar(50)=''
as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @cvname varchar(100)=case when @ClientOS='' then 'ClientVersion' else 'ClientVersion.'+@ClientOS end;

select
	(select * from (select isCurrent=case when max(case when Name=@cvname then Value end)=@ClientVersion then 'true' else 'false' end) ClientVersion for xml auto, type),
	(select * from (select isCurrent=case when max(case when Name='LCSVersion' then Value end)=@LCSVersion then 'true' else 'false' end) LCSVersion for xml auto, type)
from Config.Extensions Versions
where AdministrationID=@AdministrationID and Category='Insight'
for xml auto, elements, type
GO
