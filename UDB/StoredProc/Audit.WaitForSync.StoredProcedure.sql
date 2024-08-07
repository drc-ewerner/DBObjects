USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Audit].[WaitForSync]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc [Audit].[WaitForSync] 
	@SyncTrackingID bigint 
as
set nocount on;

declare @r bigint=(select isnull(max(SyncTrackingID),0) from Audit.SyncTracking);
declare @t int=1;
declare @w varchar(10);

while (@r<@SyncTrackingID) begin

	if (@t<=8) begin
		set @w='00:00:00.'+cast(@t as varchar);
		waitfor delay @w
		set @t*=2;
	end else begin
		waitfor delay '00:00:01';
	end;

	select @r=max(SyncTrackingID) from Audit.SyncTracking;

end;
GO
