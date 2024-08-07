USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[SubmitOnlineTest]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[SubmitOnlineTest]
	@AdministrationID int,
	@DocumentID int,
	@Method varchar(20),
	@Items xml,
	@Telemetry xml,
	@ComputerDetails xml,
	@LocalTimeOffset varchar(10) = null,
	@Timezone varchar(5) = null
as
set nocount on; set transaction isolation level read uncommitted; set xact_abort on;

declare @OnlineTestID int;
declare @CreateDate datetime=getdate();
declare @Status varchar(50);
declare @Section varchar(20);
declare @TestDuration float;

set @Section=@Items.value('(//@usage)[1]','varchar(20)');
set @TestDuration=@Items.value('(//TelemetrySummary/@duration.sec)[1]','float');

select @Status=LastProgressStatus from Document.TestTicketViewEx where AdministrationID=@AdministrationID and DocumentID=@DocumentID;

	insert Insight.OnlineTests (AdministrationID,DocumentID,Method,CreateDate,Section,ElapsedTime)
	select @AdministrationID,@DocumentID,@Method,@CreateDate,@Section,@TestDuration*1000;

	set @OnlineTestID=scope_identity();

	insert Insight.OnlineTestResponses (AdministrationID,OnlineTestID,ItemID,Position,Response,ExtendedResponse,ItemVersion)
	select AdministrationID=@AdministrationID,OnlineTestID=@OnlineTestID,ItemID=item.value('@itemId','varchar(50)'),Position=item.value('@sequence','int'),Response=case when Response='' then '-' else Response end,ExtendedResponse=case when Response is null then cast(item.query('.') as nvarchar(max)) end,ItemVersion=item.value('@itemVersion','varchar(100)')
	from @Items.nodes('//Item') d(item)
	cross apply (select Response=substring(item.value('(./response/multiplechoiceinput/mcresponse/@value)[1]','varchar(10)'),2,1)) r;

	insert Insight.OnlineTestAttachments (AdministrationID,OnlineTestID,ItemID,AttachmentID,AttachmentInputID,FilePath)
	select	AdministrationID=@AdministrationID,OnlineTestID=@OnlineTestID,
			ItemID=item.value('@itemId','varchar(50)'),
			e.attachment.value('@attachment_id', 'int') as AttachmentID,
			e.attachment.value('@input_id', 'varchar(100)') as AttachmentInputID,
			e.attachment.value('@filePath', 'varchar(max)') as FilePath
	from @Items.nodes('//Item') d(item)
	cross apply d.item.nodes('attachments/attachment') as e(attachment)

	if (@Telemetry is not null)
	insert Insight.OnlineTestTelemetry (AdministrationID,OnlineTestID,Telemetry)
	select @AdministrationID,@OnlineTestID,cast(@Telemetry as nvarchar(max));

	if (@ComputerDetails is not null) begin
	insert Insight.OnlineTestComputerDetails (AdministrationID,OnlineTestID,ComputerDetails)
	select @AdministrationID,@OnlineTestID,cast(@ComputerDetails as nvarchar(max));
	end;
	
insert Document.TestTicketStatus (AdministrationID,DocumentID,StatusTime,Status,LocalTimeOffset,Timezone)
select @AdministrationID,@DocumentID,@CreateDate,case when @Section='operational' then 'Completed-Survey Pending' else 'Completed' end,@LocalTimeOffset,@Timezone;
GO
