USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[s]    Script Date: 11/21/2023 8:54:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[s] as
select administrationId,studentId,participantId,stateStudentId,lastName,firstName,birthDate=cast(birthDate as date),createDate,updateDate,districtCode,schoolCode,gender,grade,middleName,nameSuffix,districtStudentId,schoolStudentId,vendorStudentId
from core.student
GO
