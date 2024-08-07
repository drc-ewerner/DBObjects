USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[PrintOnDemandGetNextBarcode]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[PrintOnDemandGetNextBarcode]
	@AdministrationID int,
	@RequestID int,
	@Test varchar(50),
	@Level varchar(20)

as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare
	@BarcodeFirstChars varchar(50), @BarcodeNumberLength int, 
	@BarcodeNumberMin int, @BarcodeNumberMax int, 
	@ConfigNameFirstChars varchar(100),@ConfigNameLength varchar(100), 
	@ConfigNameMin varchar(100), @ConfigNameMax varchar(100),
	@LastBarcodeNumber int, @BarcodeContent varchar(50),@ViewID int,
	@RequestType varchar(50)

declare @ViewIDTable table (n int)

select @RequestType=RequestType
from Insight.PrintOnDemandRequest
where AdministrationID=@AdministrationID and RequestID=@RequestID

set @ConfigNameFirstChars = 'PrintTestItem.'+@RequestType+'.Barcode.Content.FirstChars.'+@Test+'.'+@Level
set @ConfigNameLength = 'PrintTestItem.Barcode.Content.NumberRange.Length.'+@Test+'.'+@Level
set @ConfigNameMin = 'PrintTestItem.Barcode.Content.NumberRange.Min.'+@Test+'.'+@Level
set @ConfigNameMax = 'PrintTestItem.Barcode.Content.NumberRange.Max.'+@Test+'.'+@Level

select @BarcodeFirstChars=Insight.GetConfigExtensionValue(@AdministrationID,'eWeb',@ConfigNameFirstChars,'')
select @BarcodeNumberLength=Insight.GetConfigExtensionValue(@AdministrationID,'eWeb',@ConfigNameLength,'0')
select @BarcodeNumberMin=Insight.GetConfigExtensionValue(@AdministrationID,'eWeb',@ConfigNameMin,'0')
select @BarcodeNumberMax=Insight.GetConfigExtensionValue(@AdministrationID,'eWeb',@ConfigNameMax,'0')

if (@BarcodeNumberMin=0) set @BarcodeNumberMin=1;

select @LastBarcodeNumber=max(BarcodeNumbers)
from Insight.PrintOnDemandView
where AdministrationID=@AdministrationID and BarcodeFirstChars=@BarcodeFirstChars

if (@LastBarcodeNumber is null) set @LastBarcodeNumber=@BarcodeNumberMin-1

if (@BarcodeNumberMax>0 and @LastBarcodeNumber+1>@BarcodeNumberMax) begin
	select @RequestID,0,'Exceeded max'
	return
end;

set @BarcodeContent=case when @BarcodeNumberLength=0 then @BarcodeFirstChars+cast(@LastBarcodeNumber+1 as varchar)
	else @BarcodeFirstChars+right(replicate('0',@BarcodeNumberLength)+ 
		 cast(@LastBarcodeNumber+1 as varchar),@BarcodeNumberLength)
	end;

insert Insight.PrintOnDemandView (AdministrationID, RequestID, BarcodeFirstChars, BarcodeNumbers, BarcodeContent, ViewState)
output Inserted.ViewID into @ViewIDTable
values (@AdministrationID, @RequestID, @BarcodeFirstChars, @LastBarcodeNumber+1, @BarcodeContent, 'Requested')

select @ViewID=(select n from @ViewIDTable)

select @RequestID, @ViewID, @BarcodeContent;
GO
