USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Service].[import_submission]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Service].[import_submission]
  @incoming nvarchar(max)
as set xact_abort on;

declare @administrationId int=json_value(@incoming,'$.adminCode');
declare @documentId int=json_value(@incoming,'$.ticketId');
declare @createDate datetime=getdate();
declare @elapsedTime float=json_value(@incoming,'$.elapsedTime');
declare @method varchar(20)=json_value(@incoming,'$.method');
declare @localTimeOffset varchar(10)=json_value(@incoming,'$.timezoneOffset');
declare @timezone varchar(5)=json_value(@incoming,'$.timezone');
declare @passages table (itemId varchar(50));
declare @test varchar(50),@level varchar(20),@form varchar(20);

select @test=test,@level=level,@form=form from document.testticket where administrationId=@administrationId and documentId=@documentId;

if (@test is null) throw 50002,'invalid ticket',0;

insert insight.onlinetests (administrationId,documentId,method,createDate,section,elapsedTime)
select @administrationId,@documentId,isnull(@method,''),@createDate,'',@elapsedTime*1000;

declare @onlineTestId int=scope_identity();

insert @passages (itemId)
select itemId
from openjson(@incoming,'$.finalizedTest.responses.passages') with (itemId varchar(50));

insert insight.onlinetestresponses (administrationId,onlineTestId,itemId,position,response,extendedResponse,itemVersion)
select administrationId=@administrationId,onlineTestId=@onlineTestId,itemId,position,response=iif(answered=1,value,'-'),extendedResponse=null,itemVersion=replace(left(versionId,10)+'T'+left(right(versionId,6),2)+':'+left(right(versionId,4),2)+':'+right(versionId,2),'_','-')
from openjson(@incoming,'$.finalizedTest.responses.multipleChoices') with (itemId varchar(50),versionId varchar(50),answered bit '$.content.answered',value varchar(10) '$.content.value',content nvarchar(max) as json) i
outer apply (select position from scoring.testformitems f where f.administrationId=@administrationId and f.test=@test and f.level=@level and f.form=@form and f.itemId=i.itemId) f
where content is not null and itemId not in (select itemId from @passages);

declare @inputs table (itemId varchar(50),versionId varchar(50),flagged varchar(50),heartbeat varchar(50),heartbeatskipped varchar(50),abilityAttributeId varchar(50),scorable varchar(50),passageId varchar(50),segmentId varchar(50),sequence int,status varchar(50),fileName varchar(max),s3Bucket varchar(max),s3Key varchar(max),angleGraphInputs nvarchar(max),barGraphInputs nvarchar(max),bubbleInputs nvarchar(max),circleGraphInputs nvarchar(max),clockDrawInputs nvarchar(max),draganddropInputs nvarchar(max),dropdownInputs nvarchar(max),eqInputs nvarchar(max),graphInputs nvarchar(max),highlightInputs nvarchar(max),hotspotInputs nvarchar(max),lineInputs nvarchar(max),listInputs nvarchar(max),matchInteractionInputs nvarchar(max),matchingInputs nvarchar(max),orderInteractionInputs nvarchar(max),partitionInputs nvarchar(max),richTextInputs nvarchar(max),textInputs nvarchar(max),voiceCaptureInputs nvarchar(max));

insert @inputs (itemId,versionId,flagged,heartbeat,heartbeatskipped,abilityAttributeId,scorable,passageId,segmentId,sequence,status,fileName,s3Bucket,s3Key,angleGraphInputs,barGraphInputs,bubbleInputs,circleGraphInputs,clockDrawInputs,draganddropInputs,dropdownInputs,eqInputs,graphInputs,highlightInputs,hotspotInputs,lineInputs,listInputs,matchInteractionInputs,matchingInputs,orderInteractionInputs,partitionInputs,richTextInputs,textInputs,voiceCaptureInputs)
select itemId,versionId,flagged,heartbeat,heartbeatskipped,abilityAttributeId,scorable,passageId,segmentId,sequence,status,fileName,s3Bucket,s3Key,angleGraphInputs,barGraphInputs,bubbleInputs,circleGraphInputs,clockDrawInputs,draganddropInputs,dropdownInputs,eqInputs,graphInputs,highlightInputs,hotspotInputs,lineInputs,listInputs,matchInteractionInputs,matchingInputs,orderInteractionInputs,partitionInputs,richTextInputs,textInputs,voiceCaptureInputs
from openjson(@incoming,'$.finalizedTest.responses.constructedResponses') with (itemId varchar(50),versionId varchar(50),flagged varchar(50),heartbeat varchar(50),heartbeatskipped varchar(50),abilityAttributeId varchar(50),scorable varchar(50),passageId varchar(50),segmentId varchar(50),sequence int,status varchar(50),fileName varchar(max),s3Bucket varchar(max),s3Key varchar(max),content nvarchar(max) as json) r
outer apply openjson(r.content) with (angleGraphInputs nvarchar(max) as json,barGraphInputs nvarchar(max) as json,bubbleInputs nvarchar(max) as json,circleGraphInputs nvarchar(max) as json,clockDrawInputs nvarchar(max) as json,draganddropInputs nvarchar(max) as json,dropdownInputs nvarchar(max) as json,eqInputs nvarchar(max) as json,graphInputs nvarchar(max) as json,highlightInputs nvarchar(max) as json,hotspotInputs nvarchar(max) as json,lineInputs nvarchar(max) as json,listInputs nvarchar(max) as json,matchInteractionInputs nvarchar(max) as json,matchingInputs nvarchar(max) as json,orderInteractionInputs nvarchar(max) as json,partitionInputs nvarchar(max) as json,richTextInputs nvarchar(max) as json,textInputs nvarchar(max) as json,voiceCaptureInputs nvarchar(max) as json)
where r.content is not null and itemId not in (select itemId from @passages);;

insert insight.onlinetestattachments (administrationId,onlineTestId,itemId,attachmentId,attachmentInputId,filePath)
select administrationId=@administrationId,onlineTestId=@onlineTestId,itemId,attachmentId=1,attachmentInputId='voicecaptureinput1',fileName
from @inputs i
where fileName is not null;

insert insight.onlinetestresponses (administrationId,onlineTestId,itemId,position,response,extendedResponse,itemVersion)
select administrationId=@administrationId,onlineTestId=@onlineTestId,itemId,position,response=null,extendedResponse,itemVersion=replace(left(versionId,10)+'T'+left(right(versionId,6),2)+':'+left(right(versionId,4),2)+':'+right(versionId,2),'_','-')
from @inputs i
outer apply (select position from scoring.testformitems f where f.administrationId=@administrationId and f.test=@test and f.level=@level and f.form=@form and f.itemId=i.itemId) f
cross apply (
select 
  [@itemId],[@type]='item',[@itemVersion]=replace(left(versionId,10)+'T'+left(right(versionId,6),2)+':'+left(right(versionId,4),2)+':'+right(versionId,2),'_','-'),
  [@flagged]=nullif(flagged,'false'),[@heartbeat]=nullif(heartbeat,''),[@heartbeatskipped]=nullif(heartbeatskipped,''),[@abilityAttributeId]=nullif(abilityAttributeId,''),[@scorable]=nullif(scorable,''),[@passageId]=nullif(passageId,''),[@segmentId]=nullif(segmentId,''),[@sequence]=nullif(position,''),[@status]=nullif(status,''),
  [*]=attachments,[*]=textInputs,[*]=dropdownInputs,[*]=barGraphInputs,[*]=circleGraphInputs,[*]=angleGraphInputs,[*]=clockDrawInputs,[*]=bubbleInputs,[*]=draganddropInputs,[*]=eqInputs,[*]=graphInputs,
  [*]=highlightInputs,[*]=hotspotInputs,[*]=lineInputs,[*]=listInputs,[*]=matchInteractionInputs,[*]=matchingInputs,[*]=orderInteractionInputs,[*]=partitionInputs,[*]=richTextInputs,[*]=voiceInputs
  from (select [@itemId]=itemId) x
  outer apply (
	select [@s3Bucket]=s3Bucket,[@s3Key]=s3Key,[@filePath]=fileName,[@attachment_id]='1',[@input_id]='voicecaptureinput1'
	where fileName is not null
	for xml path('attachment'),root('attachments'),type
  ) attachments(attachments)
  outer apply service.jx_graphinputs(graphInputs)
  outer apply service.jx_textinputs(textInputs)    
  outer apply service.jx_richtextinputs(richTextInputs)
  outer apply service.jx_dropdowninputs(dropdownInputs)
  outer apply service.jx_hotspotinputs(hotspotInputs)
  outer apply service.jx_partitioninputs(partitionInputs)
  outer apply service.jx_bargraphinputs(barGraphInputs)
  outer apply service.jx_circlegraphinputs(circleGraphInputs)
  outer apply service.jx_anglegraphinputs(angleGraphInputs)
  outer apply service.jx_clockdrawinputs(clockDrawInputs)
  outer apply service.jx_bubbleinputs(bubbleInputs)
  outer apply service.jx_draganddropinputs(draganddropInputs)
  outer apply service.jx_lineinputs(lineInputs)
  outer apply service.jx_listinputs(listInputs)
  outer apply service.jx_matchinginputs(matchingInputs)
  outer apply service.jx_highlightinputs(highlightInputs)
  outer apply service.jx_matchinteractioninputs(matchInteractionInputs)
  outer apply service.jx_orderinteractioninputs(orderInteractionInputs)
  outer apply service.jx_eqinputs(eqInputs)
  outer apply service.jx_voicecaptureinputs(voicecaptureInputs)
  for xml path('Item')
) r(extendedResponse);

declare @telemetry nvarchar(max)=(
  select string_agg(t,'') within group (order by n) from (
    select n,action,t='<'+action+' '+string_agg(attr+'="'+v+'"',' ')+'/>'
    from openjson(@incoming,'$.finalizedTest.telemetry') a
    cross apply openjson(a.value) b
    cross apply openjson(b.value) c
    cross apply (select n=cast(a.[key] as int),action=case b.[key] when 'guidedaccess' then 'GuidedAccess' else upper(left(b.[key],1))+substring(b.[key],2,len(b.[key])) end,attr=c.[key],v=c.value) k
    where isjson(b.value)=1
    group by n,action
  ) t
);

insert insight.onlinetesttelemetry (administrationId,onlineTestId,telemetry)
select @administrationId,@onlineTestId,@telemetry
where @telemetry is not null;

declare @computerDetails nvarchar(max)=(
  select distinct [@name]=detailName,[@value]=value
  from openjson(@incoming,'$.finalizedTest.computerDetails') with (detailName nvarchar(max),value nvarchar(max))
  for xml path('Detail'),root('ComputerDetails')
);

insert insight.onlinetestcomputerdetails (administrationId,onlineTestId,computerDetails)
select @administrationId,@onlineTestId,@computerDetails
where @computerDetails is not null;

insert document.testticketstatus (administrationId,documentId,statusTime,status,localTimeOffset,timezone)
select @administrationId,@documentId,@createDate,'Completed',@localTimeOffset,@timezone;

select onlineTestId=@onlineTestId;
GO
