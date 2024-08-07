USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[s]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[s] as
select administrationId,studentId,participantId,stateStudentId,lastName,firstName,birthDate=cast(birthDate as date),createDate,updateDate,districtCode,schoolCode,gender,grade,middleName,nameSuffix,districtStudentId,schoolStudentId,vendorStudentId
from core.student
GO
