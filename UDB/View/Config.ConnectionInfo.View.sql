USE [Alaska_udb_dev]
GO
/****** Object:  View [Config].[ConnectionInfo]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [Config].[ConnectionInfo] as
select 
	ServerName=isnull((select r.replica_server_name
		from sys.availability_databases_cluster a
		join sys.availability_replicas r on r.group_id=a.group_id
		left join sys.dm_hadr_availability_replica_states s on s.replica_id=r.replica_id
		where a.database_name=db_name() and isnull(s.role,1)=1
	),(select data_source from sys.servers where server_id=0)),
	DatabaseName=db_name()
GO
