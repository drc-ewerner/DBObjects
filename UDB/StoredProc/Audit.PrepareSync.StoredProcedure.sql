USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Audit].[PrepareSync]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Audit].[PrepareSync]
as
set nocount on;

insert Audit.SyncTracking default values;

select SyncTrackingID=scope_identity();
GO
