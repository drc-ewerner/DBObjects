USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Audit].[PrepareSync]    Script Date: 11/21/2023 8:56:08 AM ******/
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
