USE [Alaska_udb_dev]
GO
/****** Object:  View [Document].[TestTicketView]    Script Date: 1/12/2022 1:31:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [Document].[TestTicketView] as
select AdministrationID,DocumentID,Test,Level,Form,UserName,Password,Spiraled,NotTestedCode,StartTime,EndTime=isnull(OperationalEndTime,EndTime),UnlockTime,PartName,ReportingCode,BaseDocumentID,Status=DisplayStatus,ForceSubmitMarkDate,ElapsedTime,ModuleOrder,LocalStartTime,LocalEndTime,Timezone
from Document.TestTicketViewEx t
GO
