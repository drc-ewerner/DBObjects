USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[PrintOnDemandGetBarcodes]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[PrintOnDemandGetBarcodes]
	@AdministrationID int,
	@TestSessionID int,
	@ReqString varchar(1000)

as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

IF object_id('tempdb..#r') is not null
begin
	drop table #r
end

create table #r (RequestID int, ViewID int, BarcodeContent varchar(100));

declare @Test varchar(50), @Level varchar(20) 

declare @RequestIDTable table (n int, RequestID int, RequestType varchar(100))

insert into @RequestIDTable (n, RequestID)
select * from Aux.SplitInts(@ReqString)

update @RequestIDTable set RequestType=r.RequestType
from @RequestIDTable t
inner join Insight.PrintOnDemandRequest r on r.AdministrationID=@AdministrationID and r.RequestID=t.RequestID

select @Test=Test, @Level=Level 
from Core.TestSession
where AdministrationID=@AdministrationID and TestSessionID=@TestSessionID

declare @sql varchar(max)='';


select @sql=@sql+'insert #r (RequestID, ViewID, BarcodeContent) exec Insight.PrintOnDemandGetNextBarcode '+
	cast(@AdministrationID as varchar)+','+cast(RequestID as varchar)+','''+@Test+''','''+@Level+''''+char(13)
from @RequestIDTable

exec(@sql);

select @AdministrationID as AdministrationID, * from #r

drop table #r
GO
