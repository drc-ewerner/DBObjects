USE [Alaska_udb_dev]
GO
/****** Object:  View [Document].[TestTicketViewEx]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [Document].[TestTicketViewEx] as
select AdministrationID,DocumentID,Test,Level,Form,UserName,Password,Spiraled,NotTestedCode,StartTime,EndTime,OperationalEndTime,UnlockTime,PartName,ReportingCode,BaseDocumentID,Status=isnull(case when Status='In Progress' and StartTime is null then 'Not Started' else Status end,'Not Started'),DisplayStatus=isnull(case when Status='Completed-Survey Pending' then 'Completed' when Status='In Progress' and StartTime is null then 'Not Started' else Status end,'Not Started'),LastProgressStatus=isnull(LastProgressStatus,'Not Started'),ForceSubmitMarkDate,ElapsedTime,ModuleOrder,LocalStartTime,LocalEndTime,Timezone,RegistrationID,ExternalFormID,AssessmentID,LinkDocumentID,RegenerateTime
from Document.TestTicket t
outer apply (select top(1) Status=case when Status='Unlocked' then 'In Progress' else Status end from Document.TestTicketStatus x where x.AdministrationID=t.AdministrationID and x.DocumentID=t.DocumentID and x.Status in ('Not Started','In Progress','Completed','Unlocked','Completed-Survey Pending') order by x.StatusTime desc) x
outer apply (select StartTime=min(case when Status='In Progress' then StatusTime end),EndTime=max(case when Status='Completed' then StatusTime end),OperationalEndTime=max(case when Status='Completed-Survey Pending' then StatusTime end),UnlockTime=max(case when Status='Unlocked' then StatusTime end),RegenerateTime=max(case when Status like 'Regenerated.%' then StatusTime end) from Document.TestTicketStatus x where x.AdministrationID=t.AdministrationID and x.DocumentID=t.DocumentID) y
outer apply (select top(1) LastProgressStatus = Status from Document.TestTicketStatus z where z.AdministrationID=t.AdministrationID and z.DocumentID=t.DocumentID and z.Status in ('In Progress','Completed','Completed-Survey Pending') order by z.StatusTime desc) z
outer apply (select top(1) ElapsedTime from Insight.OnlineTests ot where ot.AdministrationID=t.AdministrationID and ot.DocumentID=t.DocumentID order by ot.OnlineTestID desc) j
outer apply (select top(1) LocalStartTime=dateadd(hour,cast(substring(LocalTimeOffset,1,charindex(':',LocalTimeOffset)-1) as int),dateadd(minute,cast(substring(LocalTimeOffset,1,1) + substring(LocalTimeOffset,charindex(':',LocalTimeOffset)+1,2) as int), DATEADD(hour,DATEDIFF(hour, GETDATE(), GETUTCDATE()),StartTime))),LocalEndTime=dateadd(hour,cast(substring(LocalTimeOffset,1,charindex(':',LocalTimeOffset)-1) as int),dateadd(minute,cast(substring(LocalTimeOffset,1,1) + substring(LocalTimeOffset,charindex(':',LocalTimeOffset)+1,2) as int), DATEADD(hour,DATEDIFF(hour, GETDATE(), GETUTCDATE()),EndTime))), Timezone from Document.TestTicketStatus tts where tts.AdministrationID=t.AdministrationID and tts.DocumentID=t.DocumentID and tts.Status in ('In Progress','Completed') order by tts.StatusTime desc) l
GO
