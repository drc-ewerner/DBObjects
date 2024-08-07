USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[PrintOnDemandUpdateViewState]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[PrintOnDemandUpdateViewState]
	@AdministrationID int,
	@ViewString varchar(1000)

as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @ViewIDTable table (n int, ViewID int)

insert into @ViewIDTable (n, ViewID)
select * from Aux.SplitInts(@ViewString)

begin tran;

update Insight.PrintOnDemandView set ViewState='Success'
from @ViewIDTable t
inner join Insight.PrintOnDemandView v on v.AdministrationID=@AdministrationID and v.ViewID=t.ViewID

update Insight.PrintOnDemandRequest set ViewCount=ViewCount+1
from @ViewIDTable t
inner join Insight.PrintOnDemandView v on v.AdministrationID=@AdministrationID and v.ViewID=t.ViewID
inner join Insight.PrintOnDemandRequest r on r.AdministrationID=v.AdministrationID and r.RequestID=v.RequestID

commit tran;
GO
