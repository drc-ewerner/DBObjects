USE [Alaska_udb_dev]
GO
/****** Object:  View [Document].[TestTicketView]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [Document].[TestTicketView] as
select AdministrationID,DocumentID,Test,Level,Form,UserName,Password,Spiraled,NotTestedCode,StartTime,EndTime=isnull(OperationalEndTime,EndTime),UnlockTime,PartName,ReportingCode,BaseDocumentID,Status=DisplayStatus,ForceSubmitMarkDate,ElapsedTime,ModuleOrder,LocalStartTime,LocalEndTime,Timezone,RegistrationID,ExternalFormID,AssessmentID,LinkDocumentID,RegenerateTime
from Document.TestTicketViewEx t
GO
