USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[ValidateTicketForm]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [Insight].[ValidateTicketForm]
	@AdministrationID int,
	@DocumentID int,
	@Form varchar(20)
as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @r int;

DECLARE @Duration INT;
DECLARE @ElaspeTime INT=0;
declare @UnlockTime datetime;
declare @StartTime datetime;
declare @TimeToUse datetime;

select @Duration=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','AllowedTestDuration','0')

select @r=case when t.form=@Form then 1 else 0 end,@UnlockTime=t.UnlockTime,@StartTime=t.StartTime
from Document.TestTicketView t
join TestSession.Links k on k.AdministrationID=t.AdministrationID and k.DocumentID=t.DocumentID
where t.AdministrationID=@AdministrationID and t.DocumentID=@DocumentID --and t.Form=@Form;

if @Duration>0 begin
	if @UnlockTime is not null and @StartTime is null begin
		set @TimeToUse=null
	end else if @UnlockTime is not null and @StartTime is not null begin
		set @TimeToUse=case when @UnlockTime>@StartTime then @UnlockTime else @StartTime end
	end else begin
		set @TimeToUse=isnull(@UnlockTime,@StartTime)
	end

	if @TimeToUse is not null set @ElaspeTime=DATEDIFF(MINUTE, @TimeToUse, GETDATE())
end

select Value=case when @r=1 AND (@Duration = 0 or @ElaspeTime < @Duration)  then 'OK' else 'Invalid' end;
GO
