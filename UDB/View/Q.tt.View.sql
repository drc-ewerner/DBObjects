USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[tt]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[tt] as
select
test,
level,
form,
status,
notTestedCode,
administrationId,
studentId,
documentId,
lastName,
firstName,
username,
password,
stateStudentId,
registrationId,
participantId,
assessmentId,
externalFormId,
testSessionId,
createDate,
updateDate,
s_createDate,
s_updateDate,
testEventId,
onlineTestId,
spiraled,
startTime,
endTime,
unlockTime,
partName,
reportingCode,
baseDocumentID,
districtCode,
schoolCode,
forceSubmitMarkDate,
elapsedTime,
moduleOrder,
localStartTime,
localEndTime,
timezone
from Document.TestTicketViewEx t
cross apply (select studentid,createdate,updatedate from core.document d where d.administrationid=t.administrationid and d.documentid=t.documentid) d
outer apply (select testsessionid from testsession.links k where k.administrationid=t.administrationid and k.documentid=t.documentid) k
outer apply (select districtcode,schoolcode from core.testsession w where w.administrationid=t.administrationid and w.testsessionid=k.testsessionid) w
outer apply (select top(1) testeventid from core.testevent e where e.administrationid=t.administrationid and e.documentid=t.linkdocumentid order by testeventid desc) e1
outer apply (select top(1) onlinetestid from insight.onlinetests o where o.administrationid=t.administrationid and o.documentid=t.documentid order by onlinetestid desc) o
cross apply (select participantid,stateStudentId,lastname,firstname,s_createdate=createdate,s_updatedate=updatedate from core.student s where s.administrationid=t.administrationid and s.studentid=d.studentid) s
GO
