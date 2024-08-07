USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Service].[registration_log]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Service].[registration_log]
  @incoming nvarchar(max)
as set xact_abort on;

with i as (
  select registrationId,participantId=isnull(participantId,''),assessmentId,form,action,messageId,status,administrationId,testSessionId,studentId,documentId,data,lastError,lastErrorTime=case when lastError is not null then getdate() end
  from openjson(@incoming) with (
    registrationId varchar(100),
    participantId varchar(100),
    assessmentId varchar(100),
    form varchar(100),
    action varchar(100),
    messageId varchar(100),
    status varchar(100),
    administrationId int,
    testSessionId int,
    studentId int,
    documentId int,
    data varchar(max),
    lastError varchar(max),
    lastErrorTime datetime
  )
)
merge audit.registrationlog a
using i on i.registrationId=a.registrationId and i.participantId=a.participantId and i.assessmentId=a.assessmentId and i.messageId=a.messageId
when matched then update set status=i.status,administrationId=i.administrationId,testSessionId=i.testSessionId,studentId=i.studentId,documentId=i.documentId,data=i.data,lastError=isnull(i.lastError,a.lastError),lastErrorTime=isnull(i.lastErrorTime,a.lastErrorTime),receiveCount+=1
when not matched then insert (registrationId,participantId,assessmentId,form,action,messageId,status,administrationId,testSessionId,studentId,documentId,data,lastError,lastErrorTime,receiveCount)
values (i.registrationId,i.participantId,i.assessmentId,i.form,i.action,i.messageId,i.status,i.administrationId,i.testSessionId,i.studentId,i.documentId,i.data,i.lastError,i.lastErrorTime,1);
GO
